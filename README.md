# togglord
Simple OS X Menu Bar utility which displays weekly toggl summary for a selected project.

![screenshot](sshot.png)

## Usage

After first run, open `Proferences` from the context menu, enter your toggl API token (from [toggl web site -> my profile](https://www.toggl.com/app/profile)) and select a project for which time summary will be displayed.

## Building

togglord uses [Carthage](https://github.com/carthage/carthage) to manage framework dependencies. 
Run `carthage update` before opening `Togglord.xcodeproj`
