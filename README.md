# iArt
iOS application for _**applying styles to an image**_ and **_apply colors to grayscale or black and white images._**

Developed by [Tapaswi Satyapanthi](https://www.linkedin.com/in/tapaswi97/)

### Styling Image
This will apply the style of the selected style to the image
<table>
  <th>Capture or select the image</th>
  <th>Selected image</th>
  <th>Styled image</th>
  <tr>
    <td><img src="https://github.com/Tapaswi846580/iArt/blob/master/Images/ss_camera.PNG"></td>
    <td><img src="https://github.com/Tapaswi846580/iArt/blob/master/Images/ss_style.jpg"></td>
    <td><img src="https://github.com/Tapaswi846580/iArt/blob/master/Images/ss_styled.PNG"></td>
  </tr>
</table>

### Image Colorization
This will apply the colors to a grayscale or black and white image
<table>
  <th>Selected image</th>
  <th>Colored image</th>
  <tr>
    <td><img src="https://github.com/Tapaswi846580/iArt/blob/master/Images/ss_original_color.PNG"></td>
    <td><img src="https://github.com/Tapaswi846580/iArt/blob/master/Images/ss_colored.PNG"></td>
  </tr>
</table>

### Getting Started
1. Download or clone [iArt-Service](https://github.com/Tapaswi846580/iArt-Service) repository for image processing. (read the [description](https://github.com/Tapaswi846580/iArt-Service/blob/master/README.md) for the installation and configuration of the web the web service)
2. Download or clone this project in Xcode
3. Open CustomCameraApp.xcworkspace from the project
4. Apply the following change

Change the url in the line 233 to the url on which the backend web service is running on

Change 
```swift
let url = "http://172.20.10.2:5000/tapaswi/\(listOfImage[indexPath.row])"
```
To
```swift
let url = "http://<your ip>:5000/tapaswi/\(listOfImage[indexPath.row])"
```
**Note**: If you are using secure connection like _https_ then change ```http``` to ```https``` in the url

5. Run the app

### Outputs
#### Applying styles to an image
<table>
  <th>Original Image</th><th>Retro</th><th>Wave</th><th>Rain</th>
  <tr>
    <td><img src="https://github.com/Tapaswi846580/iArt/blob/master/Images/Style%20transfer/hamster.jpg"></td>
    <td><img src="https://github.com/Tapaswi846580/iArt/blob/master/Images/Style%20transfer/retro.JPG"></td>
    <td><img src="https://github.com/Tapaswi846580/iArt/blob/master/Images/Style%20transfer/wave.JPG"></td>
    <td><img src="https://github.com/Tapaswi846580/iArt/blob/master/Images/Style%20transfer/rain.JPG"></td>
  </tr>
  <th>Muse</th><th>Scream</th><th>Sketch</th><th>Udine</th>
  <tr>
    <td><img src="https://github.com/Tapaswi846580/iArt/blob/master/Images/Style%20transfer/muse.JPG"></td>
    <td><img src="https://github.com/Tapaswi846580/iArt/blob/master/Images/Style%20transfer/scream.JPG"></td>
    <td><img src="https://github.com/Tapaswi846580/iArt/blob/master/Images/Style%20transfer/sketch.JPG"></td>
    <td><img src="https://github.com/Tapaswi846580/iArt/blob/master/Images/Style%20transfer/udine.JPG"></td>
  </tr>
</table>


#### Coloring grayscale or black and white image
<table>
  <th>Grayscale image</th><th>Colored image</th>
  <tr>
    <td><img src="https://github.com/Tapaswi846580/iArt/blob/master/Images/Colorised/lion.JPG"></td>
    <td><img src="https://github.com/Tapaswi846580/iArt/blob/master/Images/Colorised/lion_styled.JPG"></td>
  </tr>
</table>


### Tools and Technologies used
- [Xcode 11.2](https://developer.apple.com/news/releases/?id=11122019e)
- [Alamofire](https://github.com/Alamofire/Alamofire)
- [Swifty Json](https://github.com/SwiftyJSON/SwiftyJSON)
- [Toast-Swift](https://github.com/scalessec/Toast-Swift)
- [Mac Os Mojave - 10.14.6](https://support.apple.com/kb/DL2011?locale=en_US)


### References 
[Hamster image](https://www.instagram.com/p/B5GLVs1otyA/?utm_source=ig_web_copy_link)

Image courtsey: [BBC Earth](https://www.instagram.com/bbcearth/)

Photographer: [Julian Rad](https://www.instagram.com/julianradwildlife/)
