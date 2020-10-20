//
//  DotFilter.swift
//  NISDK3
//
//  Created by Aram Moon on 2018. 2. 21..
//  Copyright © 2018년 Aram Moon. All rights reserved.
//

import Foundation

protocol FilterProtocol {
    /**
     * On filtered dot.
     */
    func onFilteredDot( _ dot : Dot);
}

/**
 * The type Filter for paper.
 */
class DotFilter {
    
    private let useFilter = true
    
    private let delta: Float = 10;
    
    private var dot1 = Dot()
    private var dot2 = Dot()
    private var makeDownDot = Dot()
    private var makeMoveDot = Dot()
    private var secondCheck = true, thirdCheck = true;
    
    private let MAX_X: Float = 15070, MAX_Y: Float = 8480;
    
    private var listener : FilterProtocol?
    
    private let MAX_OWNER = 1024;
    private let MAX_NOTE_ID = 16384;
    private let MAX_PAGE_ID = 262143;
    
    var filterQue : DispatchQueue!
    /**
     * Instantiates a new Filter for paper.
     */
    convenience init(_ listener: FilterProtocol ) {
        self.init()
        self.listener = listener
//        filterQue = DispatchQueue(label: "filter_Dot_Que")
        let id = UUID().uuidString
        filterQue = DispatchQueue(label: "filter_" + id)
    }
    
    func put(_ dot: Dot) {
        if !useFilter {
            filterQue.async {
                self.listener?.onFilteredDot(dot)
            }
            return
        }
//        filterQue.async {
            self.filterProcess(dot)
//        }
    }
    /**
     * Put dot
     */
    private func filterProcess( _ dot: Dot )
    {
        let mdot = dot
        if ( !self.validateCode(mdot) ) {
            return;
        }
        
        // Start Dot is put in the first dot.
        if ( mdot.dotType == .Down )
        {
            self.dot1 = mdot;
        }
            
            // Middle dot inserts the second and verifies from the third
            // First dot validation failure second -> first, current -> second
            // Successful first dot verification
        else if (  mdot.dotType == .Move )
        {
            // Just put it in the middle of the first
            if ( self.secondCheck )
            {
                self.dot2 = mdot;
                self.secondCheck = false;
            }
                // Middle next Dot checks Middle validation check when first verification succeeds, and next Dot when failure
            else if ( self.thirdCheck )
            {
                if ( self.validateStartDot( self.dot1, self.dot2, mdot ) )
                {
                    self.listener?.onFilteredDot( self.dot1 );
                    
                    if ( self.validateMiddleDot( self.dot1, self.dot2, mdot ) )
                    {
                        self.listener?.onFilteredDot( self.dot2 );
                        self.dot1 = self.dot2;
                        self.dot2 = mdot;
                    }
                    else
                    {
                        self.dot2 = mdot;
                    }
                }
                else
                {
                    self.dot1 = self.dot2;
                    self.dot2 = mdot;
                }
                
                self.thirdCheck = false;
            }
            else
            {
                if ( self.validateMiddleDot( self.dot1, self.dot2, mdot ) )
                {
                    self.listener?.onFilteredDot( self.dot2 );
                    self.dot1 = self.dot2;
                    self.dot2 = mdot;
                }
                else
                {
                    self.dot2 = mdot;
                }
            }
            
        }
        else if ( mdot.dotType == .Up) {
            var validateStartDotFlag = true;
            var validateMiddleDotFlag = true;
            //If only one dot is entered and only one Down 1, Move 1, End is entered
            // (Even though only one dot is entered through A_DotData in CommProcessor, Move 1, End 1 data is passed to actual processDot through A_DotUpDownData.)
            if(self.secondCheck)
            {
                self.dot2 = self.dot1;
            }
            if(self.thirdCheck &&  self.dot1.dotType == .Down )
            {
                if ( self.validateStartDot( self.dot1, self.dot2, mdot ) )
                {
                    self.listener?.onFilteredDot( self.dot1 );
                }
                else
                {
                    validateStartDotFlag = false;
                }
            }
            
            // Middle Dot Verification
            if ( self.validateMiddleDot( self.dot1, self.dot2, mdot ) )
            {
                
                if(!validateStartDotFlag)
                {
                    self.makeDownDot = mdot
                    self.makeDownDot.dotType = .Down
                    self.listener?.onFilteredDot( self.makeDownDot );
                }
                
                self.listener?.onFilteredDot( self.dot2 );
            }
            else
            {
                validateMiddleDotFlag = false;
            }
            
            // Last Dot Verification
            if ( self.validateEndDot( self.dot1, self.dot2, mdot ) )
            {
                if(!validateStartDotFlag && !validateMiddleDotFlag)
                {
                    self.makeDownDot = mdot
                    self.makeDownDot.dotType = .Down
                    self.listener?.onFilteredDot( self.makeDownDot );
                }
                if(self.thirdCheck && !validateMiddleDotFlag)
                {
                    self.makeMoveDot = mdot
                    self.makeMoveDot.dotType = .Move
                    self.listener?.onFilteredDot( self.makeMoveDot );
                }
                self.listener?.onFilteredDot( mdot );
            }
            else
            {
                self.dot2.dotType = DotType.Up;
                self.listener?.onFilteredDot( self.dot2 );
            }
            
            // Dot and variable initialization
            self.dot1 = Dot.init()
            self.dot2 = Dot.init()
            self.secondCheck = true;
            self.thirdCheck = true;
        }
    }
    
    func validateCode( _ d: Dot ) -> Bool {
        if ( MAX_NOTE_ID < Int(d.pageInfo.note) || MAX_PAGE_ID < Int(d.pageInfo.page) ) {
            return false;
        }
        return true;
    }
    
    // ==============================================
    // Use 3 points
    // Directionality and Delta X, Delta Y
    // ==============================================
    
    func validateStartDot( _ vd1: Dot, _ vd2: Dot, _ vd3: Dot) -> Bool
    {
        let d1 = vd1
        let d2 = vd2
        let d3 = vd3
        if ( d1.x > MAX_X || d1.x < 1 ){
            return false
        }
        
        if ( d1.y > MAX_Y || d1.y < 1 ) {
            return false
        }
        let d123x = (d3.x > d1.x) == (d2.x > d1.x)
        let d13x = abs( d3.x - d1.x)
        let d12x = abs( d1.x - d2.x )
        if d123x && (d13x > self.delta) && (d12x > self.delta )
        {
            return false
        }
        let d123y = (d3.y > d1.y) == (d2.y > d1.y)
        let d13y: Float = abs( d3.y - d1.y )
        let d12y: Float = abs( d1.y - d2.y )
        if  d123y && (d13y > self.delta) && (d12y > self.delta )
        {
            return false
        }
        return true
        
    }
    
    func validateMiddleDot( _ vd1: Dot, _ vd2: Dot, _ vd3: Dot ) -> Bool
    {
        let d1 = vd1
        let d2 = vd2
        let d3 = vd3
        if ( d2.x > MAX_X || d2.x < 1 ) {
            return false
        }
        
        if ( d2.y > MAX_Y || d2.y < 1 ){
            return false
        }
        
        let d123x = (d3.x > d2.x) == (d1.x > d2.x)
        let d23x: Float = abs( d3.x - (d2.x))
        let d12x: Float = abs( (d1.x) - (d2.x) )
        if d123x && (d23x > self.delta) && (d12x > self.delta)
        {
            return false
        }
        
        let d123y = (d1.y > d2.y) == (d3.y > d2.y)
        let d13y = abs( (d3.y) - (d2.y) )
        let d12y = abs( (d1.y) - (d2.y) )
        if d123y && (d13y > self.delta) && (d12y > self.delta )
        {
            return false
        }
        return true
        
    }
    
    func validateEndDot( _ vd1: Dot, _ vd2: Dot, _ vd3: Dot) -> Bool {
        let d1 = vd1
        let d2 = vd2
        let d3 = vd3
        if ( d3.x > MAX_X || d3.x < 1 ) {
            return false
        }
        
        if ( d3.y > MAX_Y || d3.y < 1 ) {
            return false
        }
        
        if ( (d3.x > d1.x) == (d3.x > d2.x) && abs( (d3.x) - (d1.x) ) > delta && abs( (d3.x) - (d2.x) ) > delta ) {
            return false
        } else if ( (d3.y > d1.y) == (d3.y > d2.y) && abs( (d3.y) - (d1.y) ) > delta && abs( (d3.y) - (d2.y) ) > delta ) {
            return false
        }
        return true
    }
}

