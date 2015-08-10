//
//  FiltersViewController.swift
//  Coursica
//
//  Created by Regan Bell on 8/5/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography
import RealmSwift

let unselectedGray = UIColor(white: 217/255.0, alpha: 1)

protocol FiltersViewControllerDelegate {
    
    func filtersDidChange()
    func keyboardShouldDismiss()
}

class FiltersViewController: UIViewController {

    @IBOutlet var genEdButtons: [UIButton]!
    @IBOutlet var genEdLabels: [UILabel]!
    @IBOutlet var cards: [UIView]!
    @IBOutlet var genEdImageViews: [UIImageView]!
    @IBOutlet var termBarButtons: [UIButton]!
    @IBOutlet var termBarLabels: [UILabel]!
    @IBOutlet var gradBarButtons: [UIButton]!
    @IBOutlet var gradBarLabels: [UILabel]!
    
    @IBOutlet var termBarView: UIView!
    @IBOutlet var genEdBarView: UIView!
    
    @IBOutlet var scrollView: UIScrollView!
    
    var qOverallSlider: NMRangeSlider!
    var qWorkloadSlider: NMRangeSlider!
    var enrollmentSlider: NMRangeSlider!
    
    var selectedTermIndex = 0
    var selectedGradIndex = 0
    
    @IBOutlet var filterCoursesButton: UIButton!
    
    var delegate: FiltersViewControllerDelegate?
    var filters: NSPredicate {
        let predicateOptions: [NSPredicate?] = [gradPredicate(), termPredicate(), overallPredicate(), workloadPredicate(), enrollmentPredicate(), genEdPredicate()]
        var filters: [NSPredicate] = []
        for predicateOption in predicateOptions {
            if let predicate = predicateOption {
                filters.append(predicate)
            }
        }
        return NSCompoundPredicate.andPredicateWithSubpredicates(filters)
    }
    
    func gradPredicate() -> NSPredicate? {
        switch selectedGradIndex {
        case 0:  return NSPredicate(format: "graduate = %@", NSNumber(bool: false))
        case 1:  return NSPredicate(format: "graduate = %@", NSNumber(bool: true))
        default: return nil
        }
    }
    
    func termPredicate() -> NSPredicate? {
        switch selectedTermIndex {
        case 0:  return NSPredicate(format: "term = %@", "FALL")
        case 1:  return NSPredicate(format: "term = %@", "SPRING")
        default: return nil
        }
    }
    
    func overallPredicate() -> NSPredicate? {
        if qOverallSlider.upperValue > 4.9 && qOverallSlider.lowerValue < 1.1 {
            return nil
        } else {
            return NSPredicate(format: "overall >= %f AND overall <= %f", qOverallSlider.lowerValue, qOverallSlider.upperValue)
        }
    }
    
    func workloadPredicate() -> NSPredicate? {
        if qWorkloadSlider.upperValue > 4.9 && qWorkloadSlider.lowerValue < 1.1 {
            return nil
        } else {
            return NSPredicate(format: "workload >= %f AND workload <= %f", qWorkloadSlider.lowerValue, qWorkloadSlider.upperValue)
        }
    }
    
    func enrollmentPredicate() -> NSPredicate? {
        let lowerPredicate = NSPredicate(format: "enrollment >= %d", Int(enrollmentSlider.lowerValue))
        if Int(enrollmentSlider.upperValue) < 250 {
            let upperPredicate = NSPredicate(format: "enrollment <= %d", Int(enrollmentSlider.upperValue))
            return NSCompoundPredicate.andPredicateWithSubpredicates([lowerPredicate, upperPredicate])
        } else {
            return lowerPredicate
        }
    }
    
    func genEdPredicate() -> NSPredicate? {
        var selectedGenEdButton: UIButton? = nil
        for button in genEdButtons {
            if button.selected == true {
                selectedGenEdButton = button
            }
        }
        if let selected = selectedGenEdButton {
            
            let genEds = ["Aesthetic and Interpretive Understanding",
                          "Culture and Belief",
                          "Empirical and Mathematical Reasoning",
                          "Ethical Reasoning",
                          "Science of Living Systems",
                          "Science of the Physical Universe",
                          "Societies of the World",
                          "United States in the World",
                          "Study of the Past"]
            
            return NSPredicate(format: "ANY genEds.name = %@", genEds[selected.tag])
        } else {
            return nil
        }
    }
    
    @IBAction func filterCoursesButtonPressed(button: UIButton) {
        delegate?.filtersDidChange()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for imageView in genEdImageViews {
            imageView.image = imageView.image?.imageWithRenderingMode(.AlwaysTemplate)
            imageView.tintColor = unselectedGray
        }
        for card in cards {
            card.layer.cornerRadius = 4
            card.clipsToBounds = true
        }
        filterCoursesButton.layer.cornerRadius = 4
        filterCoursesButton.clipsToBounds = true
        let pairs: [([UIButton], Selector)] = [(genEdButtons, "genEdButtonPressed:"), (termBarButtons, "termButtonPressed:"), (gradBarButtons, "gradButtonPressed:")]
        for pair in pairs {
            let (buttons, selector) = pair
            for (index, button) in enumerate(buttons) {
                button.tag = index
                button.addTarget(self, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
        scrollView.keyboardDismissMode = .OnDrag
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
        scrollView.addSubview(genEdBarView)
        
        selectButton(termBarButtons.last!, labels: termBarLabels, buttons: termBarButtons)
        selectButton(gradBarButtons.last!, labels: gradBarLabels, buttons: gradBarButtons)
        layoutSliders()
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        delegate?.keyboardShouldDismiss()
    }
    
    func selectButton(selectedButton: UIButton, labels: [UILabel], buttons: [UIButton]) {
        delegate?.keyboardShouldDismiss()
        selectedButton.selected = !selectedButton.selected
        labels[selectedButton.tag].textColor = selectedButton.selected ? coursicaBlue : unselectedGray
        for button in buttons {
            if button.selected && button.tag != selectedButton.tag {
                button.selected = false
                labels[button.tag].textColor = unselectedGray
            }
        }
    }
    
    func gradButtonPressed(button: UIButton) {
        selectedGradIndex = button.tag
        selectButton(button, labels: gradBarLabels, buttons: gradBarButtons)
    }
    
    func termButtonPressed(button: UIButton) {
        selectedTermIndex = button.tag
        selectButton(button, labels: termBarLabels, buttons: termBarButtons)
    }
    
    func genEdButtonPressed(pressedButton: UIButton) {
        delegate?.keyboardShouldDismiss()
        let selected = !pressedButton.selected
        for button in genEdButtons {
            button.selected == false
            genEdImageViews[button.tag].tintColor = unselectedGray
            genEdLabels[button.tag].textColor = unselectedGray
        }
        pressedButton.selected = selected
        let newColor = selected ? coursicaBlue : unselectedGray
        genEdLabels[pressedButton.tag].textColor = newColor
        genEdImageViews[pressedButton.tag].tintColor = newColor
    }
    
    func layoutSliderWithTitle(title: String) -> DoubleSliderView {
        let font = UIFont(name: "AvenirNext-Medium", size: 14)
        let textColor = UIColor(white: 155/255.0, alpha: 1)
        let sliderView = DoubleSliderView(title: title, font: font, textColor: textColor)
        scrollView.addSubview(sliderView)
        constrain(sliderView, genEdBarView, {slider, genEdBar in
            slider.left == genEdBar.left + 18
            slider.right == genEdBar.right - 18
            slider.height == 52
        })
        return sliderView
    }
    
    func layoutSliders() {
        let overallSliderView = layoutSliderWithTitle("Overall Q Score")
        overallSliderView.shouldFormatForFloatValue = true
        overallSliderView.valueChanged(overallSliderView.slider)
        qOverallSlider = overallSliderView.slider
        constrain(overallSliderView, genEdBarView, {overall, genEdBar in
            overall.top == genEdBar.bottom + 16
        })
        
        let workloadSliderView = layoutSliderWithTitle("Workload")
        workloadSliderView.shouldFormatForFloatValue = true
        workloadSliderView.valueChanged(workloadSliderView.slider)
        qWorkloadSlider = workloadSliderView.slider
        constrain(workloadSliderView, overallSliderView, {workload, overall in
            workload.top == overall.bottom + 16
        })
        
        let enrollmentSliderView = layoutSliderWithTitle("Enrollment")
        enrollmentSliderView.shouldFormatForFloatValue = false
        enrollmentSlider = enrollmentSliderView.slider
        enrollmentSlider.minimumValue = 1
        enrollmentSlider.maximumValue = 250
        enrollmentSlider.upperValue = 250
        enrollmentSliderView.valueChanged(enrollmentSliderView.slider)
        constrain(enrollmentSliderView, workloadSliderView, {enrollment, workload in
            enrollment.top == workload.bottom + 16
        })
    }
}
