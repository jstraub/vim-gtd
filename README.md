# Getting Things Done in vim
vim-gtd provides all functionality to manage your life from a single .gtd file
under the "Getting Things Done" paradigm of David Allen. 

The syntax follows Markdown closely so that it becomes easy to convert the file to .html.

# Getting Started
Copy the gtd.gtd file and start filling in your own contexts first. After you
entered your contexts and saved, they will ACTIONS, WAITING and DONE will
automatically be populated with them.

    # CONTEXTS
      ## home
      ## office

Now you can start populating the file with your actions, waitings and dones! Dont forget to add the appropriate tags: ACT for actions, WAIT for waiting and DONE for done in front of the respective task description.

    # ACTIONS
      ## home
        ACT repair lamp
      ## office
    # WAITING
      ## home
        WAIT room mate returns monitor
      ## office
    # DONE
      ## home 
      ## office
        DONE get new mouse from IT

You can add additional information below each task:
    
    # ACTIONS
      ## home
        ACT repair lamp
          - lamp is in the left drawer of the bedroom
          - use the yellow LED lamp

# Optional Requirements
Optionally vim-gtd can use mutt to send individual ACT or WAIT tasks as well as
whole contexts to your own email so you have access to it on your smart-phone.

# Functionality
Several functions are supported to make keeping the file clean and orderly easy:
- you can toggle through ACT -> WAIT -> DONE using ''
- upon saving tasks are automatically moved to the designated sections (i.e. a task in section ACTIONS tagged WAIT is moved into section WAITING)
