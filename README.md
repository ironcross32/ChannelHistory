# ChannelHistory

## Virtual buffering system for screen reader users.

## Installation instructions
In Mudlet, type the following command:
`lua uninstallPackage("ChannelHistory");installPackage("https://github.com/ironcross32/ChannelHistory/releases/download/V1.0.0/ChannelHistory.mpackage")`
## Usage

for those who are familiar with the channel_history plugin for MUSHclient, this package behaves in much the same way, though with a more limited feature set.
* Alt+left/Alt+right - navigate between categories in the virtual buffer
* Alt+up/Alt+down - navigate through the messages in the selected category
* Alt+home/Alt+end - jump to the first and last message in the selected category
* Alt+Shift+T - Toggles hearing relative time that a given message entered the buffer
* Alt+Shift+delete - removes the selected category along with all of its messages

Holding the alt key and tapping a number from 1 to 0 on the number row will retrieve a recent message. For example, Alt+1 would retrieve the most recent message, while Alt+5 would retrieve the fifth most, and Alt+0 would retrieve the tenth most recent message. While holding alt, double tapping a number will have its message copied to the clipboard.

To add a new message to any given buffer, simply call `channel_history.add(STR category_name, STR message)`. Here's an example of a regular expression trigger:

`\[(chat|advice|events)\] (\w+)(.+s)`

And, how this information is parsed and passed along to `channel_history:add()`

```
local where = matches[2]
local message = matches[3] .. ": " .. matches[4]
channel_history.add(where, message)
```

## Credits

As much of this project is a port from channel_history.xml from MushZ, thanks goes out to its authors:
* Tyler Spivey
* Oriol Gómez
* Weyoun

Thanks also goes to Demonnic for graciously offering assistance with questions related to Muddler, which is used to package this project, and for helping with debugging some initial code. And of course, to the Mudlet team as a hole for creating a fast, powerful, and feature-rich MUD client.