# xkcd_assignment
xkcd comic browser

## 🖌️ Application

![Image](https://user-images.githubusercontent.com/39621438/222983170-c84d0439-2bf5-4274-8c06-806a5e7986ce.png)
![Image](https://user-images.githubusercontent.com/39621438/222983165-f0f2ee0c-2fb1-4869-ab17-de5e48aada94.png)
![Image](https://user-images.githubusercontent.com/39621438/222983167-ee56f191-90d4-49ff-9f49-288ceef7b14c.png)
![Image](https://user-images.githubusercontent.com/39621438/222983169-1b13767a-3267-4382-a76a-3c56a51df55a.png)
![Image](https://user-images.githubusercontent.com/39621438/222983166-403b4510-882a-4165-bb10-43fbfd0733d7.png)

## ⚙️ Functionalities

I decided at the very beginning which functionalities to add to my MVP and which ones to leave out due to time constraints. 

The repo project is how I usually keep track of tasks, so I created [this one](https://github.com/users/TijanaGrbo/projects/5/views/1) and added an issue for each requirement. The ones I decided to leave out are in the Backlog, just in case I stumbled upon some extra time lying around (which I haven't).

### 📝 **The requirement overview:**

The search requirement is separated in two parts: by number and by text.

- [x] browse through the comics,
- [x] see the comic details, including its description,
- [x] search for comics by the comic number (search part 1 of 2)
- [x] get the comic explanation
- [x] favorite the comics, which would be available offline too,
- [x] send comics to others,
- [ ] search for comics by the text (search part 2 of 2) - the provided search by the text wasn't functional
- [ ] get notifications when a new comic is published,
- [ ] support multiple form factors.

## 🏗️ Architecture

### 🖼️ Framework: UIKit

As my primary focus was SwiftUI, I chose UIKit for this project to get more comfortable with it.

### 📐 Architectural pattern: MVVM

I've used the combination of MVVM and Coordinator pattern with .xib files. MVVM is convenient because it provides a clear separation of UI from logic and data.

### 🧭 Navigation: Coordinator pattern

Coordinator pattern is a convenient way to add the missing navigation layer when the Storyboard is omitted from the project, but it's also easy to edit and maintain. It helps in separating navigation logic from the view controllers and makes the code more modular and testable.

### 📱 UI: .xib + programmatic

Even though Storyboards and .xib files have similar drawbacks (clunky, impossible to resolve conflicts if two people edit the same file), .xib files are reusable, which makes the code more modular, but also easier to maintain because they're smaller and don't control the navigation. It might be worth noting that I would only use programmatic approach without .xibs on a bigger project with other collaborators.

### 🪢 Data Binding: Combine

Data binding would have been a pain point if I didn't use just right amount of combine to bind @Published properties from ViewModels to ViewController properties.

### 🧩 Modularity: Protocols

I wanted to reduce code duplication by reusing one View Controller with two View Models, so I created a protocol to which they both would conform. It's convenient to have the same methods with slightly different implementations if necessary.

### 🗃️ Local Storage: Core Data

I've used Core Data framework because it provides a pretty straightforward way to store and manage app data, making it easy to access and manipulate. Transformable with custom classes and transformers allows for more flexibility if necessary. It was helpful for storing images.

### 🛠️ Testing: XCTest

XCTest provided an essential foundation for UI testing. I've written some simple navigation tests and would have expanded them if I had more time.

### 👁️🦻 Accessibility: Native

I've used accessibility labels and hints to configure buttons and labels and enable alt text for images.

## 📱 Views

### 📒 Browse

Browse view is displaying the data from the xkcd API. When Favourite button is tapped, the comic is saved locally using Core Data, where it's available for further use in...

### 💖 Favourites

Favourites displays the local data with help from the good guy Core Data. The comics can be unfavourited from this view, which deletes them from the local storage. If the local storage is empty (there are no favourite comics), a message is displayed.

### 🔍 Search

Search uses a slider to select the number of a comic you want to get. I've implemented search by the comic number since the search by the text wasn't functional.

### 🕵️ Details

Details is a sheet that opens on image tap. It displays the comic title, alt text and a button that links to the explanation.

## Conclusion

I had tons of fun making this app 🎉
