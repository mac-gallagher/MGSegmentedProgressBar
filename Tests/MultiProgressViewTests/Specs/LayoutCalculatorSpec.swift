//
//  LayoutCalculatorSpec.swift
//  MultiProgressViewTests
//
//  Created by Mac Gallagher on 3/5/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

import Quick
import Nimble

@testable import MultiProgressView

class LayoutCalculatorSpec: QuickSpec {
    override func spec() {
        describe("LayoutCalculator") {
            let numberOfSections: Int = 2
            let progressViewWidth: CGFloat = 200
            let progressViewHeight: CGFloat = 50
            
            var mockDataSource: MockMultiProgressViewDataSource!
            var progressView: TestableMultiProgressView!
            var subject: LayoutCalculator!
            
            beforeEach {
                mockDataSource = MockMultiProgressViewDataSource(numberOfSections: numberOfSections)
                
                let progressViewFrame = CGRect(x: 0, y: 0,
                                               width: progressViewWidth,
                                               height: progressViewHeight)
                progressView = TestableMultiProgressView()
                progressView.frame = progressViewFrame
                progressView.dataSource = mockDataSource
                
                subject = LayoutCalculator()
            }
            
            //MARK: - Track Frame
            
            describe("Track Frame") {
                context("When calling the trackFrame function") {
                    let trackInset: CGFloat = 10
                    
                    beforeEach {
                        progressView.trackInset = trackInset
                    }
                    
                    context("and the line cap type is butt") {
                        beforeEach {
                            progressView.lineCap = .butt
                        }
                        
                        it("should return the correct track frame") {
                            let actualFrame = subject.trackFrame(forProgressView: progressView)
                            let expectedFrame = CGRect(x: 0,
                                                       y: trackInset,
                                                       width: progressViewWidth,
                                                       height: progressViewHeight - 2 * trackInset)
                            expect(actualFrame).to(equal(expectedFrame))
                        }
                    }
                    
                    context("and the line cap type is round") {
                        beforeEach {
                            progressView.lineCap = .round
                        }
                        
                        it("should return the correct track frame") {
                            let actualFrame = subject.trackFrame(forProgressView: progressView)
                            let expectedFrame = CGRect(x: trackInset,
                                                       y: trackInset,
                                                       width: progressViewWidth - 2 * trackInset,
                                                       height: progressViewHeight - 2 * trackInset)
                            expect(actualFrame).to(equal(expectedFrame))
                        }
                    }
                    
                    context("and the line cap type is square") {
                        beforeEach {
                            progressView.lineCap = .square
                        }
                        
                        it("should return the correct track frame") {
                            let actualFrame = subject.trackFrame(forProgressView: progressView)
                            let expectedFrame = CGRect(x: trackInset,
                                                       y: trackInset,
                                                       width: progressViewWidth - 2 * trackInset,
                                                       height: progressViewHeight - 2 * trackInset)
                            expect(actualFrame).to(equal(expectedFrame))
                        }
                    }
                }
            }
            //MARK: - Section Frame
            
            describe("Section Frame") {
                context("When calling the sectionFrame function") {
                    let trackBounds = CGRect(x: 10, y: 20, width: 30, height: 40)
                    let section: Int = 1
                    
                    beforeEach {
                        progressView.track.bounds = trackBounds
                    }
                    
                    context("and there is no progress on the section") {
                        let progress: Float = 0
                        
                        beforeEach {
                            progressView.setProgress(section: section, to: progress)
                        }
                        
                        it("should return the correct frame with zero width") {
                            let actualFrame = subject.sectionFrame(forProgressView: progressView,
                                                                   section: section)
                            let expectedFrame = CGRect(x: trackBounds.origin.x,
                                                       y: trackBounds.origin.y,
                                                       width: 0,
                                                       height: trackBounds.height)
                            expect(actualFrame).to(equal(expectedFrame))
                        }
                    }
                    
                    context("and there is some progress on the section and the section before it has zero width") {
                        let progress: Float = 0.5
                        
                        beforeEach {
                            progressView.setProgress(section: section, to: progress)
                        }
                        
                        it("should return the correct frame with the proper width") {
                            let actualFrame = subject.sectionFrame(forProgressView: progressView,
                                                                   section: section)
                            let expectedWidth = trackBounds.width * CGFloat(progress)
                            let expectedFrame = CGRect(x: trackBounds.origin.x,
                                                       y: trackBounds.origin.y,
                                                       width: expectedWidth,
                                                       height: trackBounds.height)
                            expect(actualFrame).to(equal(expectedFrame))
                        }
                    }
                    
                    context("and there is some progress on the section and the section before it has a nonzero width") {
                        let firstSectionFrame = CGRect(x: 0, y: 0, width: 30, height: 0)
                        let progress: Float = 0.2
                        
                        beforeEach {
                            progressView.progressViewSections[0].frame = firstSectionFrame
                            progressView.setProgress(section: section, to: progress)
                        }
                        
                        it("should return the correct frame with the proper width and origin") {
                            let actualFrame = subject.sectionFrame(forProgressView: progressView,
                                                                   section: section)
                            
                            let expectedOrigin = CGPoint(x: trackBounds.origin.x + firstSectionFrame.width,
                                                         y: trackBounds.origin.y)
                            let expectedSize = CGSize(width: trackBounds.width * CGFloat(progress),
                                                      height: trackBounds.height)
                            let expectedFrame = CGRect(origin: expectedOrigin, size: expectedSize)
                            
                            expect(actualFrame).to(equal(expectedFrame))
                        }
                    }
                }
            }
            
            //MARK: - Track Image View Frame
            
            describe("Track Image View Frame") {
                context("When calling the trackImageViewFrame function") {
                    let trackBounds = CGRect(x: 10, y: 20, width: 30, height: 40)
                    
                    beforeEach {
                        progressView.track.bounds = trackBounds
                    }
                    
                    it("should return the track's bounds") {
                        let actualFrame = subject.trackImageViewFrame(forProgressView: progressView)
                        expect(actualFrame).to(equal(trackBounds))
                    }
                }
            }
            
            //MARK: - Section Image View Frame
            
            describe("Section Image View Frame") {
                context("When calling the sectionImageViewFrame function") {
                    let sectionBounds = CGRect(x: 1, y: 2, width: 3, height: 4)
                    var section: ProgressViewSection!
                    
                    beforeEach {
                        section = progressView.progressViewSections[0]
                        section.bounds = sectionBounds
                    }
                    
                    it("should return the section's bounds") {
                        let actualFrame = subject.sectionImageViewFrame(forSection: section)
                        expect(actualFrame).to(equal(sectionBounds))
                    }
                }
            }
            
            //MARK: - Corner Radius
            
            describe("Corner Radius") {
                context("When calling the cornerRadius function") {
                    context("and the line cap type is butt") {
                        beforeEach {
                            progressView.lineCap = .butt
                        }
                        
                        it("should return zero") {
                            let actualCornerRadius = subject.cornerRadius(forProgressView: progressView)
                            expect(actualCornerRadius).to(equal(0))
                        }
                    }
                    
                    context("and the line cap type is square") {
                        beforeEach {
                            progressView.lineCap = .square
                        }
                        
                        it("should return zero") {
                            let actualCornerRadius = subject.cornerRadius(forProgressView: progressView)
                            expect(actualCornerRadius).to(equal(0))
                        }
                    }
                    
                    context("and the line cap type is round and corner radius is equal to zero") {
                        beforeEach {
                            progressView.lineCap = .round
                            progressView.cornerRadius = 0
                        }
                        
                        it("should return half the height of the progressView") {
                            let actualCornerRadius = subject.cornerRadius(forProgressView: progressView)
                            expect(actualCornerRadius).to(equal(progressViewHeight / 2))
                        }
                    }
                    
                    context("and the line cap type is round and corner radius is nonzero") {
                        let cornerRadius: CGFloat = 5
                        
                        beforeEach {
                            progressView.lineCap = .round
                            progressView.cornerRadius = cornerRadius
                        }
                        
                        it("should return the progressView's corner radius") {
                            let actualCornerRadius = subject.cornerRadius(forProgressView: progressView)
                            expect(actualCornerRadius).to(equal(cornerRadius))
                        }
                    }
                }
            }
            
            //MARK: - Track Corner Radius
            
            describe("Track Corner Radius") {
                context("When calling the trackCornerRadius function") {
                    context("and the line cap type is butt") {
                        beforeEach {
                            progressView.lineCap = .butt
                        }
                        
                        it("should return zero") {
                            let actualCornerRadius = subject.trackCornerRadius(forProgressView: progressView)
                            expect(actualCornerRadius).to(equal(0))
                        }
                    }
                    
                    context("and the line cap type is square") {
                        beforeEach {
                            progressView.lineCap = .square
                        }
                        
                        it("should return zero") {
                            let actualCornerRadius = subject.trackCornerRadius(forProgressView: progressView)
                            expect(actualCornerRadius).to(equal(0))
                        }
                    }
                    
                    context("and the line cap type is round and corner radius is equal to zero") {
                        let trackBounds = CGRect(x: 0, y: 0, width: 0, height: 500)
                        
                        beforeEach {
                            progressView.track.bounds = trackBounds
                            progressView.lineCap = .round
                            progressView.cornerRadius = 0
                        }
                        
                        it("should return half the height of the track") {
                            let actualCornerRadius = subject.trackCornerRadius(forProgressView: progressView)
                            expect(actualCornerRadius).to(equal(trackBounds.height / 2))
                        }
                    }
                    
                    context("and the line cap type is round and corner radius is nonzero") {
                        let trackBounds = CGRect(x: 0, y: 0, width: 0, height: 500)
                        let cornerRadius: CGFloat = 5
                        var cornerRadiusFactor: CGFloat!
                        
                        beforeEach {
                            progressView.track.bounds = trackBounds
                            progressView.lineCap = .round
                            progressView.cornerRadius = cornerRadius
                            cornerRadiusFactor = cornerRadius / progressViewHeight
                        }
                        
                        it("should return the correct scaled corner radius") {
                            let actualCornerRadius = subject.trackCornerRadius(forProgressView: progressView)
                            let expectedCornerRaduis = cornerRadiusFactor * trackBounds.height
                            expect(actualCornerRadius).to(equal(expectedCornerRaduis))
                        }
                    }
                }
            }
            
            //MARK: Layout Anchoring
            
            describe("Layout Anchoring") {
                context("When calling the anchorToSuperview function") {
                    let insets = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
                    var view: UIView!
                    
                    beforeEach {
                        view = UIView()
                    }
                    
                    context("and the view has no superview") {
                        it("should return no constraints") {
                            let actualConstraints = subject.anchorToSuperview(view,
                                                                              withAlignment: .bottom,
                                                                              insets: insets)
                            expect(actualConstraints).to(equal([]))
                        }
                    }
                    
                    context("and the view has a superview") {
                        let superview: UIView = UIView()
                        var topConstraint: NSLayoutConstraint!
                        var leftConstraint: NSLayoutConstraint!
                        var rightConstraint: NSLayoutConstraint!
                        var bottomConstraint: NSLayoutConstraint!
                        var centerXConstraint: NSLayoutConstraint!
                        var centerYConstraint: NSLayoutConstraint!
                        
                        beforeEach {
                            superview.addSubview(view)
                            
                            topConstraint = view.topAnchor.constraint(equalTo: superview.topAnchor,
                                                                      constant: insets.top)
                            leftConstraint = view.leftAnchor.constraint(equalTo: superview.leftAnchor,
                                                                        constant: insets.left)
                            rightConstraint = view.rightAnchor.constraint(equalTo: superview.rightAnchor,
                                                                          constant: -insets.right)
                            bottomConstraint = view.bottomAnchor.constraint(equalTo: superview.bottomAnchor,
                                                                            constant: -insets.bottom)
                            centerXConstraint = view.centerXAnchor.constraint(equalTo: superview.centerXAnchor,
                                                                              constant: insets.left - insets.right)
                            centerYConstraint = view.centerYAnchor.constraint(equalTo: superview.centerYAnchor,
                                                                              constant: insets.top - insets.bottom)
                        }
                        
                        context("and the alignment is equal to top") {
                            it("should return the correct layout constraints") {
                                let actualConstraints = subject.anchorToSuperview(view,
                                                                                  withAlignment: .top,
                                                                                  insets: insets)
                                expect(actualConstraints.count).to(equal(2))
                                expect(actualConstraints.contains(centerXConstraint)).to(beTrue())
                                expect(actualConstraints.contains(topConstraint)).to(beTrue())
                            }
                        }
                        
                        context("and the alignment is equal to topLeft") {
                            it("should return the correct layout constraints") {
                                let actualConstraints = subject.anchorToSuperview(view,
                                                                                  withAlignment: .topLeft,
                                                                                  insets: insets)
                                expect(actualConstraints.count).to(equal(2))
                                expect(actualConstraints.contains(topConstraint)).to(beTrue())
                                expect(actualConstraints.contains(leftConstraint)).to(beTrue())
                            }
                        }
                        
                        context("and the alignment is equal to left") {
                            it("should return the correct layout constraints") {
                                let actualConstraints = subject.anchorToSuperview(view,
                                                                                  withAlignment: .left,
                                                                                  insets: insets)
                                expect(actualConstraints.count).to(equal(2))
                                expect(actualConstraints.contains(centerYConstraint)).to(beTrue())
                                expect(actualConstraints.contains(leftConstraint)).to(beTrue())
                            }
                        }
                        
                        context("and the alignment is equal to bottomLeft") {
                            it("should return the correct layout constraints") {
                                let actualConstraints = subject.anchorToSuperview(view,
                                                                                  withAlignment: .bottomLeft,
                                                                                  insets: insets)
                                expect(actualConstraints.count).to(equal(2))
                                expect(actualConstraints.contains(bottomConstraint)).to(beTrue())
                                expect(actualConstraints.contains(leftConstraint)).to(beTrue())
                            }
                        }
                        
                        context("and the alignment is equal to bottom") {
                            it("should return the correct layout constraints") {
                                let actualConstraints = subject.anchorToSuperview(view,
                                                                                  withAlignment: .bottom,
                                                                                  insets: insets)
                                expect(actualConstraints.count).to(equal(2))
                                expect(actualConstraints.contains(centerXConstraint)).to(beTrue())
                                expect(actualConstraints.contains(bottomConstraint)).to(beTrue())
                            }
                        }
                        
                        context("and the alignment is equal to bottomRight") {
                            it("should return the correct layout constraints") {
                                let actualConstraints = subject.anchorToSuperview(view,
                                                                                  withAlignment: .bottomRight,
                                                                                  insets: insets)
                                expect(actualConstraints.count).to(equal(2))
                                expect(actualConstraints.contains(bottomConstraint)).to(beTrue())
                                expect(actualConstraints.contains(rightConstraint)).to(beTrue())
                            }
                        }
                        
                        context("and the alignment is equal to right") {
                            it("should return the correct layout constraints") {
                                let actualConstraints = subject.anchorToSuperview(view,
                                                                                  withAlignment: .right,
                                                                                  insets: insets)
                                expect(actualConstraints.count).to(equal(2))
                                expect(actualConstraints.contains(centerYConstraint)).to(beTrue())
                                expect(actualConstraints.contains(rightConstraint)).to(beTrue())
                            }
                        }
                        
                        context("and the alignment is equal to topRight") {
                            it("should return the correct layout constraints") {
                                let actualConstraints = subject.anchorToSuperview(view,
                                                                                  withAlignment: .topRight,
                                                                                  insets: insets)
                                expect(actualConstraints.count).to(equal(2))
                                expect(actualConstraints.contains(rightConstraint)).to(beTrue())
                                expect(actualConstraints.contains(topConstraint)).to(beTrue())
                            }
                        }
                        
                        context("and the alignment is equal to center") {
                            it("should return the correct layout constraints") {
                                let actualConstraints = subject.anchorToSuperview(view,
                                                                                  withAlignment: .center,
                                                                                  insets: insets)
                                expect(actualConstraints.count).to(equal(2))
                                expect(actualConstraints.contains(centerXConstraint)).to(beTrue())
                                expect(actualConstraints.contains(centerYConstraint)).to(beTrue())
                            }
                        }
                    }
                }
            }
        }
    }
}

//MARK: - NSLayoutConstraint Testable Helpers

extension NSLayoutConstraint {
    open override func isEqual(_ object: Any?) -> Bool {
        guard let constraint = object as? NSLayoutConstraint else { return false }
        
        guard let firstItem = firstItem as? UIView,
            let constraintFirstItem = constraint.firstItem as? UIView else { return false }
        
        guard let secondItem = secondItem as? UIView,
            let constraintSecondItem = constraint.secondItem as? UIView else { return false }
        
        guard relation == constraint.relation,
            constant == constraint.constant,
            constant == constraint.constant,
            firstItem == constraintFirstItem,
            secondItem == constraintSecondItem,
            multiplier == constraint.multiplier,
            firstAttribute == constraint.firstAttribute,
            secondAttribute == constraint.secondAttribute else { return false }
        
        return true
    }
}
