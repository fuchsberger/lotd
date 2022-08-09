## 1.1.4
  - on tabbing in the search field is autoselected and all text highlighted
  - search field works for all columns and while using, ignores all filters
  - filters reapply on emptying the search field
  - when focusing on search field auto-highlights all text
  - fixed bug that required toggle to click twice

## 1.1.3
  - shows by default 100 entries and the option to select rows was removed
  - sub-filters for displays/locations/rooms/regions switched to selects
  - clicking on a filter in the item list shows all items with that filter
  - searching for an item ignores all currently selected filters
  - improved performance in item table: ordering done via database and removed order options. now always sorts by name.

## 1.1.2
  - column filters on item page now in header combined with ordering
  - some unsortable columns are now sortable
  - issue fixed with edit button for moderation

## 1.1.1
  - improved performance by reducing file size that needs to be loaded by about 40% and loading via ajax after inital page load
  - interactivity and all actions now via ajax
  - reduced number of sql queries
  - on first log in no character is created automatically anylonger
  - mods are now toggled globally (for all characters)
  - character limit of 10 was removed
  - management of system should be much easier for moderators and admins now

## 1.1
  - mod tag now showing on mods
  - readded ability to modify mods
  - character creation via modals
  - loading table and toggling items now happens via ajax (much faster)
  - table layout set to fixed and responsive (the bigger the screen the more info)
  - individual filters for item location region display and room
  - pagination, ordering, changing table size

## 1.0
  - creating a character auto-activates it
  - completely redesigned GUI with full mobile support
  - much more performant as all data is loaded up-front and then dynamically displayed
  - improved search (now using FuzzyCompare.ChunkSet.standard_similarity for much better results)
  - improved account security and secure session handling
  - avatar from nexus now being displayed when logged in
  - mods can now be toggled on and off collectively
  - improved moderation system
  - when moderating will update the system for all users on the fly
  - entering an invalid item url no longer possible thus the page can no longer be broken this way


## 0.6.4

### New Features
  - safety confirmation before deleting things
  - the app will now remember your hide items selection

### Enhancments
  - Syntax Highlighting in item names on search
  - Searching happens now on database level (performance optimized)
  - Filtering happens now on search
  - searching also improved in manage view
  - items and locations are now autoupdated whenever elements change
  - improved save button
  - Toned down visibility of replica icon
  - only admins can now delete stuff

## 0.6.3

### New Features
  - Added Replica Support

## 0.6.2

### Enhancments
  - Improved Filtering in Admin View
  - Displays can now only be filtered if a room or display is currently being filtered.
  - Locations can now only be filtered if a region or location is currently being filtered.

# 0.6

### New Features
  - Locations now belong to a region
  - Columns are filterable and hide automatically according to screen size
  - Characters can now be created / edited on mobile devices

### Enhancments
  - Separated management from Gallery view
  - Improved Gallery view (table format) that displays further information about items.
  - Improved Character page and added legend.

### Bug Fixes
  - When hitting ENTER in a search field it would redirect to a 404 page



## 0.5.7

### New Features
  - Admins can now see a list of characters (names and item counts) that each user has.
  - Moderators can now see a list of characters (item counts only) that each user has.

### Bug Fixes
  - http://lotd.fuchsberger.us, https://www.lotd.fuchsberger.us, and https://www.lotd.fuchsberger.us will now all properly redirect to https://lotd.fuchsberger.us avoiding infinite loader issue when accessing page via www.

## 0.5.6

### Enhancments
  - when hide mode is on it will now hide completed displays, mods and locations as well.

### Bug Fixes
  - Fixed missing validation for required url field when adding/updating mods

## 0.5.5

### Enhancements
  - performance improvements in gallery page by reducing queries
  - on creating new characters, Legacy of the Dragonborn Mod will be auto-activated
  - moderators can now always see all content

### Bug Fixes
  - Fixed a critical bug that prevented new users from registration
  - Item count display in bottom bar was always showing 0/0
  - removed Nexus Logo and replaced with icon (couldn't get it to display with new static assets procedure, may eventually come back)

## 0.5.4

### New Features
  - admins and moderators can view a list of users and their admin/moderation status
  - admins can promote / demote users to admin / moderator

### Bug Fixes
  - Fixed a critical bug that prevented new users from registration

## 0.5.3

### Enhancments
  - increased padding in Item List to make mobile experience better

### Bug Fixes
  - "ok" text removed from items in list when not logged in
  - Gallery lists do now display proberly on Safari browsers
