import Foundation
import UIKit

public class AutoCompleteTextField: UITextField {
    
    /// Manages the instance of tableview
    private var autoCompleteTableView = UITableView()
    
    /// Handles user selection action on autocomplete table view
    public var onSelect: (String, NSIndexPath) -> () = {_,_ in}
    
    /// Handles textfield's textchanged
    public var onTextChange: (String) -> () = {_ in}
    
    /// Label text aligment
    public var autoCompleteTextAligment: NSTextAlignment = .left
    
    /// Label text insets
    public var autoCompleteLabelInsets: UIEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
    
    /// Font for the text suggestions
    public var autoCompleteTextFont = UIFont.systemFont(ofSize: 12)
    
    /// Color of the text suggestions
    public var autoCompleteTextColor: UIColor = .black
    
    /// Used to set the height of cell for each suggestions
    public var autoCompleteCellHeight: CGFloat = 44.0
    
    /// The maximum visible suggestion
    public var maximumAutoCompleteCount = 3
    
    /// Used to set your own preferred separator inset
    public var autoCompleteSeparatorInset: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
    
    /// Hides autocomplete tableview after selecting a suggestion
    public var hidesWhenSelected = true
    
    /// Hides autocomplete tableview when the textfield is empty
    public var hidesWhenEmpty:Bool = true {
        didSet{
            autoCompleteTableView.isHidden = hidesWhenEmpty
        }
    }
    
    /// The table view height
    public var autoCompleteTableHeight: CGFloat = 100 {
        didSet{
            redrawTable()
        }
    }
    
    /// The strings to be shown on as suggestions, setting the value of this automatically reload the tableview
    public var autoCompleteStrings: [String] = [] {
        didSet{
            filteredAutoCompleteStrings = autoCompleteStrings
            reload()
        }
    }
    
    private var filteredAutoCompleteStrings: [String] = []
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        setupAutocompleteTable(on: superview)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
        setupAutocompleteTable(on: superview)
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        commonInit()
        setupAutocompleteTable(on: newSuperview)
    }
    
    private func commonInit() {
        hidesWhenEmpty = true
        clearButtonMode = .always
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }
    
    private func setupAutocompleteTable(on view: UIView?) {
        guard let view = view else { return }
        
        let screenSize = UIScreen.main.bounds.size
        let tableView = UITableView(frame: CGRect(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.height, width: screenSize.width - (self.frame.origin.x * 2), height: 30))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = autoCompleteCellHeight
        tableView.isHidden = hidesWhenEmpty
        tableView.separatorInset = autoCompleteSeparatorInset
        tableView.layoutMargins = autoCompleteSeparatorInset

        view.addSubview(tableView)
        
        autoCompleteTableView = tableView
        autoCompleteTableHeight = 100
    }
    
    private func redrawTable() {
        var newFrame = autoCompleteTableView.frame
        let allCellsHeight = CGFloat(filteredAutoCompleteStrings.count) * autoCompleteCellHeight
        
        if autoCompleteTableHeight > allCellsHeight {
            newFrame.size.height = allCellsHeight
        } else {
            newFrame.size.height = autoCompleteTableHeight
        }
        
        autoCompleteTableView.frame = newFrame
    }
    
    //MARK: - Private Methods
    private func reload() {
        autoCompleteTableView.reloadData()
    }
    
    @objc func textFieldDidChange() {
        guard let text = text else {
            return
        }
        
        onTextChange(text)
        
        filteredAutoCompleteStrings = autoCompleteStrings.filter({$0.lowercased().contains(text.lowercased())})
        
        DispatchQueue.main.async {
            self.redrawTable()
            self.reload()
            
            if self.hidesWhenEmpty, self.filteredAutoCompleteStrings.count == 0 {
                self.autoCompleteTableView.isHidden = true
            } else {
                self.autoCompleteTableView.isHidden = false
            }
        }
    }
    
    @objc func textFieldDidEndEditing() {
        autoCompleteTableView.isHidden = true
    }
}

//MARK: - UITableViewDataSource - UITableViewDelegate
extension AutoCompleteTextField: UITableViewDataSource, UITableViewDelegate {
  
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAutoCompleteStrings.count > maximumAutoCompleteCount ? maximumAutoCompleteCount : filteredAutoCompleteStrings.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "autocompleteCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            
            cell?.contentView.gestureRecognizers = nil
            
            let cellBounds = cell?.contentView.bounds ?? CGRect()
            
            let width = cellBounds.width - autoCompleteLabelInsets.left - autoCompleteLabelInsets.right
            let frame = CGRect(x: autoCompleteLabelInsets.left, y: cellBounds.origin.y, width: width, height: cellBounds.height)
            
            let label = UILabel(frame: frame)
            label.tag = 1
            label.textAlignment = autoCompleteTextAligment
            label.font = autoCompleteTextFont
            label.textColor = autoCompleteTextColor
            
            cell?.contentView.addSubview(label)
        }
        
        
        let textLabel = cell?.contentView.viewWithTag(1) as? UILabel
        textLabel?.text = filteredAutoCompleteStrings[indexPath.item]
        
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if let selectedText = (cell?.contentView.viewWithTag(1) as? UILabel)?.text {
            self.text = selectedText
            onSelect(selectedText, indexPath as NSIndexPath)
        }
        
        DispatchQueue.main.async {
            tableView.isHidden = self.hidesWhenSelected
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return autoCompleteCellHeight
    }
}
