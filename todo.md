Toggle is Admin 

// lib/services/services/edit_history.dart
// lib/navbar/notifications.dart
// lib/utils/utility.dart

[X] - Done
[ ] - yet to be done
[T] - To be tested
[P] - in progress
[?] - Unsure if it is right way

### TODO

PRE(=E;Rel)
- [ ] - Add a way to add a new service
- [X] SignedIn User's state should update.
- [X] Remove '\n' from synonyms using Edit Page.
- [X] BottomnNavigation background color as per UI.
- [X] Edit a word and add to edit history table.
- [X] Notification Detail on request approval the difference is not visible as it is compared against the current version.
- [X] Add a feedback system
- [X] Add a new word should be intelligent to recognize duplicates dynamically.
- [X] Add a about section for the app
- [ ] Create onBoarding screens for app tour.
- [ ] Difference is not shown correctly
- [ ] Deeplink to shared word
- [ ] Implement notification system
- [ ] Send report via email add subject in link
- [ ] Before adding to history check if duplicate edit exists.
- [ ] Ensure the fonts are consistent across the app.
- [ ] Add deeplinking to specific word from share feature
- [ ] Add mechanism to generate screenshots of app.


- [ ] Dark theme for the app.
- [X] Add a feature to notify app update.
- [ ] Create a reputation system for users.
- [ ] Forum Tab to show edit and new word proposals user can only upvote or downvote the proposal.

### Forum (Reputation rules)

- [ ] Any one can propose a new word or edit a word. And that post will be shown up in this section.
- [ ] Forum posts should be ordered by recents or no of votes or type(edits/new word).
- [ ] A new word can only be approved, if it has 25+ votes.
- [ ] Add a new word +10 Reputation (on Approve of the word)
- [ ] A negative upvote on a post will result in -5 Reputation and the post will be deleted.
- [ ] Make a successful edit +2 Reputation

Ans:

### Notifications

- [X] A user should see his edit/add requests and status under notifications.
- [X] A admin should be able to see all the requests and approve/reject them.
- [X] Edit visualizer: When admin taps on the request it should show a page with differences in current word and the edit request.

### Dashboard

- [X] Slide Animation on Explore Page
- [X] A word of the day card should be shown on Dashboard
- [X] A word of the day should be updated when the first user comes online in the server timezone.
- [X] Mastered/Bookmarked words should be visible on Dashboard.
- [X] User should be able to update the status of mastered/bookmarked words.

### Word Detail Page

- [ ] Add typewriter animation to meaning of the word.
- [ ] Ability to see history of edits made for that word.

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
- [ ] Stats should show contribution details of the user. e.g tapping on under review should
redirect to new page with all the edits.
- [ ] Tapping on each contribution should redirect to the edit visualizer.
- [ ] Pull down to refresh.

#### Contributions

- [?] Make a new contribution table to store all the contributions of the user.
     userId, email, reputation,
- [ ] Based on above contribution assign reputation points to user
- [ ] Show contributions on profile page

### Questions to Ponder
- User makes same requests multiple times, should we allow that?

- User tries adding a existing word.
Ans Check if word exist while adding a new word

- Multiple users try adding same word. (Two requests pending for same word)
Ans:

- Two edit requests pending for same word.
Ans: 

- If a user is deleted from the database, what happens to use Contributions?
Ans: A default user will be shown, wherever required with name being "Deleted User";

- Word Edit History link with vocabhub table in database, How many past edits?
Ans:

- smart Search based on meaning and synonyms (Query)?
Ans: SELECT * FROM vocabsheet_copy
WHERE word LIKE '%a clo%' OR
 meaning LIKE '%a clos%'
