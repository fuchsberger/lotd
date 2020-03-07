## 0.6.4

### Enhancments
  - Syntax Highlighting in item names on search
  - Searching happens now on database level (performance optimized)
  - Filtering happens now on search
  - Toned down visibility of replica icon

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
