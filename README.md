# ChatBot-in-Flutter-FlowBot
FlowBot - JSON Driven Dynamic ChatBot
To view the whole working video you can go through my LinkedIn post :
https://www.linkedin.com/posts/prabalpandey08_flutter-chatbot-ai-activity-7299175143627464704-TI9n?utm_source=share&utm_medium=member_desktop&rcm=ACoAAD1_oTkBngQB66OdExQKHfK5-76oi-7_fTE

This bot operates based on a JSON file structure that defines its flow. Below are the different types of nodes and their functionalities.
Features of the Bot:
1. You do not have to change anything in the code just create a json file, save the json file in assets section with .json extension and add it under the assests section in pubspec.yaml. Now just aupdate the fileName in main.dart with your specified file name and the bot is ready.
2. To make it more interactive, I have used Flutter's talk to speech module which speaks out each bot question and responds to user interactions(when user selects any option or clicks the next button). You can customize what to respond in the JSON file.
3. The Bot have following type of nodes:
   Single-Select (Radio) Node which includes -
         radioTypeWithAttachments – Each option has an associated media attachment (image, video, or audio) and,
         radioTypeWithTextOnly – Options share a common set of images.
   
   Multi-Select (Checkbox) Nodes which includes -
         checkbox – Options are displayed as cards with media attachments.
         checkboxInRowView – Options are displayed in a row, with a “View More” button for additional attachments.
         checkboxInGridView – Options are displayed in a grid layout, with a “View More” button.
     💡 Recommendation : Use checkboxInRowView or checkboxInGridView if there are too many attachments to avoid clutter.

   Multimedia Node
         multimedia – Captures user input through image uploads, video recordings, or audio recordings.

   Label Nodes (For Bot Messages)
         label – Displays a message and automatically triggers the next node.
         labelWithNext – Displays a message, but the flow continues only when the user clicks "Next".
4. In the images you add multiple image links and the images will be presented in form of a carousel.
5. It also have a functionality of layover data to show text over the images. (text in layoverData[i] will be mapped with the image in image[i])

Here are some of its working image
![VideoCapture_1](https://github.com/user-attachments/assets/49aa0cb0-5051-4cf8-9771-fe51cf90ec2d)
![VideoCapture_2](https://github.com/user-attachments/assets/f17457f1-3a28-4998-9854-c92693528ef7)
![VideoCapture_3](https://github.com/user-attachments/assets/10f06530-d265-4c27-9d7f-632bc9fceb01)
![VideoCapture_4](https://github.com/user-attachments/assets/f865e0a7-6f22-408b-ba19-a7e6eb092bec)
![VideoCapture5](https://github.com/user-attachments/assets/0c21ef02-c6fc-48a9-a7ad-1c25993aeeef)
![VideoCapture_6](https://github.com/user-attachments/assets/19e5ab5d-8fce-4ca8-afae-921112f6e2b8)
