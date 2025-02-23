# ChatBot-in-Flutter-FlowBot
FlowBot - JSON Driven Dynamic ChatBot
This bot operates based on a JSON file structure that defines its flow. Below are the different types of nodes and their functionalities.
Features of the Bot:
1. You do not have to change anything in the code just create a json file, save the json file in assets section with .json extension and add it under the assests section in pubspec.yaml. Now just aupdate the fileName in main.dart with your specified file name and the bot is ready.
2. The Bot have following type of nodes:
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
3. In the images you add multiple image links and the images will be presented in form of a carousel.
4. It also have a functionality of layover data to show text over the images. (text in layoverData[i] will be mapped with the image in image[i])
