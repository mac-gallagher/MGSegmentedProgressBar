//
//  ProgressViewSection.swift
//  MultiProgressView
//
//  Created by Mac Gallagher on 6/15/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

open class ProgressViewSection: UIView {
    
    public var titleLabel: UILabel {
        return sectionTitleLabel
    }
    
    private var sectionTitleLabel: UILabel = UILabel()
    
    public var titleEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var titleAlignment: AlignmentType = .center {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var imageView: UIImageView {
        return sectionImageView
    }
    
    private var sectionImageView: UIImageView = UIImageView()
    
    private var layoutCalculator: LayoutCalculatable = LayoutCalculator.shared
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    convenience init(layoutCalculator: LayoutCalculatable) {
        self.init(frame: .zero)
        self.layoutCalculator = layoutCalculator
    }
    
    private func initialize() {
        backgroundColor = .black
        layer.masksToBounds = true
        addSubview(sectionImageView)
        addSubview(sectionTitleLabel)
    }
    
    // MARK: - Layout
    
    var labelConstraints = [NSLayoutConstraint]() {
        didSet {
            NSLayoutConstraint.deactivate(oldValue)
            NSLayoutConstraint.activate(labelConstraints)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        labelConstraints = layoutCalculator.anchorToSuperview(sectionTitleLabel,
                                                              withAlignment: titleAlignment,
                                                              insets: titleEdgeInsets)
        sectionImageView.frame = layoutCalculator.sectionImageViewFrame(forSection: self)
        sendSubviewToBack(sectionImageView)
    }
    
    // MARK: - Main Methods
    
    public func setTitle(_ title: String?) {
        sectionTitleLabel.text = title
    }
    
    public func setAttributedTitle(_ title: NSAttributedString?) {
        sectionTitleLabel.attributedText = title
    }
    
    public func setImage(_ image: UIImage?) {
        sectionImageView.image = image
    }
}
