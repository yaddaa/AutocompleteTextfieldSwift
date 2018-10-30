# AutocompleteTextFieldSwift
Simple and straightforward sublass of UITextfield to manage string suggestions

Plain        | Attributed
------------- | -------------
![Plain](http://i.imgur.com/SvyLreh.png?1) 


## Installation
Drag AutoCompleteTextField Folder in your project

## How to use

#### Customize
Customize autocomplete suggestions! You can override the provided properties to create your desired appearance.
Properties are pretty self explanatory. Some of them are listed below, with their respective default values:

```
/// Font for the text suggestions
public var autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12)
/// When set to true, shows autocomplete text with formatting
public var enableAttributedText = false
/// User Defined Attributes
public var autoCompleteAttributes:[String:AnyObject]?
/// Hides autocomplete tableview after selecting a suggestion
public var hidesWhenSelected = true
```


#### Setting Content
The most important property to use is the `autoCompleteStrings`. As what is declared in the description setting the value of this will automatically reload the tableview, through the use of `didSet`
 ```
/// The strings to be shown on as suggestions, setting the value of this automatically reload the tableview
public var autoCompleteStrings:[String]?{
    didSet{ reload() }
}
  ```


#### User Interactions
To handle text changed event, use `onTextChange:` closure. This returns the current text content of the textfield.
```
autocompleteTextfield.onTextChange = {[weak self] text in 
// your code goes here
...
}
```
To know when user selected a text, use `onSelect:` closure: This returns the selected text and it's indexPath.

```
autocompleteTextfield.onSelect = {[weak self] text, indexpath in
// your code goes here
...
}
```
It's that easy! Feel free to use it, don't worry, it's free. :)

## License
AutocompleteTextfield is under [MIT license](http://opensource.org/licenses/MIT). See LICENSE for details.
