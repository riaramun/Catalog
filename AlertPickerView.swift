//
//  AlertPickerView.swift
//  AlertPickerView




import Foundation
import UIKit


class AlertPickerView: UIView {
    var pickerView: UIPickerView!
    var pickerToolbar: UIToolbar!
    var toolbarItems: [UIBarButtonItem]!
    var items:Array<String>!
    let heightOfPickerView:CGFloat = 120
    let heightOfToolbar:CGFloat = 44
    var backgroundColorOfPickerView  = UIColor.whiteColor()
    var backgroundColorOfToolbar = UIColor.whiteColor()
    var textColorOfToolbar = UIColor.blackColor()

    var delegate: AlertPickerViewDelegate? {
        didSet {
            pickerView.delegate = delegate
        }
    }
    private var selectedRows: [Int]?


    override init(frame: CGRect) {
        super.init(frame: frame)
        initFunc()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initFunc()
        print("initfunc")
    }

    private func initFunc() {
        let screenSize = UIScreen.mainScreen().bounds.size
        self.backgroundColor = UIColor.blackColor()

        pickerToolbar = UIToolbar()
        pickerView = UIPickerView()
        toolbarItems = []

        pickerToolbar.translucent = false
        pickerView.showsSelectionIndicator = true
        pickerView.backgroundColor = self.backgroundColorOfPickerView


        self.frame = CGRectMake(0, screenSize.height, screenSize.width, self.heightOfPickerView + self.heightOfToolbar)

        //pickerToolbar
        pickerToolbar.frame = CGRectMake(0, 0, screenSize.width, self.heightOfToolbar)
        pickerToolbar.barTintColor = self.backgroundColorOfPickerView

        //pickerView
        pickerView.frame = CGRectMake(0, self.heightOfToolbar, screenSize.width, self.heightOfPickerView)
        pickerView.backgroundColor = self.backgroundColorOfPickerView


        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        space.width = 12

        
        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)

        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("endPicker"))
        
        let cancelItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelPicker")

        toolbarItems! += [space, cancelItem, flexSpaceItem, doneButtonItem, space]
        pickerToolbar.setItems(toolbarItems, animated: false)
        pickerToolbar.tintColor = self.textColorOfToolbar
        pickerToolbar.barTintColor = self.backgroundColorOfToolbar


        self.addSubview(pickerToolbar)
        self.addSubview(pickerView)
    }
    func showPicker() {
        if selectedRows == nil {
            selectedRows = getSelectedRows()
        }
        delegate?.pickerViewWillShow?(pickerView)
        let screenSize = UIScreen.mainScreen().bounds.size

        UIView.animateWithDuration(0.2 ,animations: { () -> Void in

            self.frame = CGRectMake(0, screenSize.height - (self.heightOfToolbar + self.heightOfPickerView), screenSize.width, self.heightOfPickerView + self.heightOfToolbar)

            }) { (completed:Bool) -> Void in
        self.delegate?.pickerViewDidSHow?(self.pickerView)
        }
    }



    func cancelPicker() {
        hidePicker()
        restoreSelectedRows()
        selectedRows = nil
    }
    func endPicker() {
        hidePicker()
        delegate?.pickerView?(pickerView, didSelect: getSelectedRows())
        selectedRows = nil
    }
    private func hidePicker() {
        let screenSize = UIScreen.mainScreen().bounds.size
        delegate?.pickerViewWillHide?(pickerView)
        UIView.animateWithDuration(0.2 ,animations: { () -> Void in

             self.frame = CGRectMake(0, screenSize.height, screenSize.width, self.heightOfToolbar + self.heightOfPickerView)

            }) { (completed:Bool) -> Void in
        self.delegate?.pickerViewDidHide?(self.pickerView)
        }
    }
    private func getSelectedRows() -> [Int] {
        var selectedRows = [Int]()
        for i in 0 ... pickerView.numberOfComponents - 1 {
            selectedRows.append(pickerView.selectedRowInComponent(i))
        }
        return selectedRows
    }
    private func restoreSelectedRows() {
        for i in 0..<selectedRows!.count {
            pickerView.selectRow(selectedRows![i], inComponent: i, animated: true)
        }
    }
}

@objc
protocol AlertPickerViewDelegate: UIPickerViewDelegate {
    optional func pickerView(pickerView: UIPickerView, didSelect numbers: [Int])
    optional func pickerViewDidSHow(pickerView: UIPickerView)
    optional func pickerViewDidHide(pickerView: UIPickerView)
    optional func pickerViewWillHide(pickerView: UIPickerView)
    optional func pickerViewWillShow(pickerView: UIPickerView)
    optional func pickerViewDidShow(pickerView: UIPickerView)

}
