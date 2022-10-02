Toggle is Admin 

// lib/services/services/edit_history.dart
// lib/navbar/notifications.dart
// lib/utils/utility.dart


[X] - Done
[ ] - yet to be done
[T] - To be tested
[P] - in progress

### TODO

- [X] SignedIn User's state should update.
- [X] Remove '\n' from synonyms using Edit Page.
- [X] BottomnNavigation background color as per UI.
- [X] Edit a word and add to edit history table.
- [ ] Ensure the fonts are consistent across the app.
- [ ] Dark theme for the app.
- [ ] Before adding to history check if duplicate edit exists.
- [ ] Add a feature to notify app update.
- [ ] Create onBoarding screens for app tour.
- [ ] Create a reputation system for users.
- [ ] Forum Tab to show edit and new word proposals user can only upvote or downvote the proposal.

### Reputation

- [ ] Add a new word +10 Reputation (on Approve of the word)
- [ ] Make a successful edit +2


### Notifications

- [ ] A user should see his edit/add requests and status under notifications.
- [X] A admin should be able to see all the requests and approve/reject them.
- [ ] Edit visualizer: When admin taps on the request it should show a page with differences in current word and the edit request.

### Dashboard

- [X] Slide Animation on Explore Page
- [X] A word of the day card should be shown on Dashboard
- [T] A word of the day should be updated when the first user comes online in the server timezone.
- [X] Mastered/Bookmarked words should be visible on Dashboard.
- [X] User should be able to update the status of mastered/bookmarked words.

### Word Detail Page

- [ ] Add typewriter animation to meaning of the word.

### Search

- [ ] Redesign Search.
- [X] Going to search tab should have a dummy search bar.
- [ ] Initial content will be some random words and popular words on platform.
- [X] Tapping on search bar should show recent searches and execute search.
- [ ] Search should be intelligent to allow searching by word, meaning, synonyms, antonyms, etc.

### explore page

- [X] Explore should fetch words in pagination from by querying 20 words at a time.(Configurable number)
- [X] Initially random 20 words will be fetched and then on scroll 20 more words will be fetched But the known words should not be repeated (Unknown status and random only).
- [ ] If user is not logged In, user can simply swipe all words and a login prompt should be shown on every 5th or 10th word.
- [ ] Scroll Animation should be shown only for the first time user visits the explore page.

### User Profile

- [ ] User should be able to update his profile (username, profile picture)
- [ ] User Profile should show his Reputation on the platform.
- [ ] Add a LeaderBoard Redirecion from profile page.
#### Contributions

- [ ] Based on above contribution assign reputation points to user
- [ ] Show contributions on profile page