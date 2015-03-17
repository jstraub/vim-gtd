# Getting Things Done in vim
vim-gtd provides all functionality to manage your life from a single .gtd file
under the "Getting Things Done" paradigm of David Allen. 
The syntax follows Markdown closely so that it becomes easy to convert the file to .html.

vim-gtd will allow you to manage your life and projects from within vim. The
plugin's functionality makes it easy to keep the gtd file clean and orderly.

- advance your projects within your unique self-defined contexts
- define your projects and contexts
- keep track of actions, waitings and dones
- easily change the status of tasks and re-sort them into their respective sections

## Getting Started
Copy the gtd.gtd file and start filling in your own contexts first. After you
entered your contexts and saved, they will ACTIONS, WAITING and DONE will
automatically be populated with them.
```
# CONTEXTS
  ## home
  ## office
```
Now you can start populating the file with your actions, waitings and dones!
Dont forget to add the appropriate tags: ACT for actions, WAIT for waiting and
DONE for done in front of the respective task description.  You can add
additional information below each task.
```
# ACTIONS
  ## home
    ACT repair lamp
      - lamp is in the left drawer of the bedroom
      - use the yellow LED lamp
  ## office
# WAITING
  ## home
    WAIT room mate returns monitor
  ## office
# DONE
  ## home 
  ## office
    DONE get new mouse from IT
```

## Functionality
Several functions are supported to make keeping the file clean and orderly easy:

### key-combinations
- cycle through ACT -> WAIT -> DONE using `''`
- re-sort all actions, waitings and dones into the respective sections using `'r`

If you specified a email program in the configuration using `set email = ` you
can easily send tasks or whole contexts to a specified email-address using the
key combination `'e` while the cursor is in the line of the task or context you
would like to send. All additional information will be sent as well (as
designated by a higher indentation level).
This e-mail functionality makes it easy to be productive while on the move from
you smart-phone.

### options
- upon saving tasks are automatically moved to the designated sections (i.e. a task in section ACTIONS tagged WAIT is moved into section WAITING)


