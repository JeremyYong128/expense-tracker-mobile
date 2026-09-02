# Application Architecture

## Folder Structure

- **lib/**
  - **ui/**: Contains all user interface elements.
    - **screens/**: Full-page views that the user navigates between.
      - `add_transaction_screen.dart`: Screen for adding new transactions.
      - `credit_card_details_screen.dart`: Shows transaction history and stats for a specific credit card.
      - `credit_cards_screen.dart`: Lists all credit cards and allows adding/editing them.
      - `dashboard_screen.dart`: The main home screen showing summary statistics, top categories, and rewards.
      - `history_screen.dart`: A chronologically grouped list of all past transactions.
      - `manage_screen.dart`: A navigation hub for managing recurring transactions, credit cards, etc.
      - `recurring_transactions_screen.dart`: Lists all recurring transactions.
      - `settings_screen.dart`: App settings (e.g., language, text casing preferences).
    - **widgets/**: Reusable UI components, forms, and modals.
      - `category_appearance_picker_modal.dart`: A modal to select icons and colors for a category.
      - `category_modal.dart`: A modal to create, edit, or manage categories.
      - `category_picker_modal.dart`: A modal used in forms to select an existing category.
      - `credit_card_modal.dart`: A modal form to add or edit a credit card.
      - `custom_date_picker_field.dart`: A styled form field that opens a date picker.
      - `custom_dropdown_field.dart`: A reusable dropdown input field.
      - `custom_switch.dart`: A styled toggle switch.
      - `custom_time_picker_field.dart`: A styled form field that opens a time picker.
      - `custom_validated_field.dart`: A wrapper that provides validation error text formatting for custom form fields.
      - `edit_transaction_modal.dart`: A modal wrapper around `transaction_form.dart` to edit an existing transaction.
      - `pending_approvals_dialog.dart`: A dialog that prompts the user to approve pending recurring transactions.
      - `slide_up_modal.dart`: A base layout component for creating consistent, draggable bottom sheet modals.
      - `transaction_form.dart`: The core form component used for both adding and editing transactions.
      - `transaction_type_toggle.dart`: A segmented control to toggle between Income and Expense.
  - **core/**: Core domain logic and error handling.
    - `exceptions.dart`: Custom exceptions like `DatabaseValidationException`.
  - **services/**: Handles business logic and data access.
    - `data_service.dart`: Handles all database queries.
    - `recurring_processing_service.dart`: Logic for detecting and processing due recurring transactions.
  - **providers/**: State management using the Provider package.
    - `category_provider.dart`: State for categories.
    - `credit_card_provider.dart`: State for credit cards.
    - `recurring_transaction_provider.dart`: State for recurring transactions.
    - `transaction_provider.dart`: State for standard transactions.
    - `user_preferences_provider.dart`: Manages global user settings like text casing and localization.
  - **utils/**: Utility classes, extensions, and constants.
    - `app_theme.dart`: Centralized design system, colors, text styles, and layout padding.
    - `category_appearance.dart`: Data structures and constants for category icons and colors.
    - `string_extensions.dart`: Extension methods for string manipulation (e.g., casing).
    - `validators.dart`: Reusable validation logic for forms.
  - **models/**: Data models (e.g., `transaction.dart`, `category.dart`, `credit_card.dart`, `recurring_transaction.dart`).
  - **database/**: Drift database configuration and tables (`drift_database.dart`, `drift_database.g.dart`).
  - `main.dart`: App entry point and root tab navigation scaffold.

# Form Validation

## Validation

### 1. UI-Level Validation

For validation that does not require database queries, we do it through UI-level checks. These are implemented by the `CustomValidatedField` wrappers, which accept the form field and also validation functions (`utils/validators.dart`). This renders an error message below the form field itself if validation fails.

### 2. Database-Level Validation

Form submission functions have a try/catch block that catch any `DatabaseValidationError` and stores the error message in the `_formError` field. This appears as a message at the top of the form for users.

# Recurring Transactions

## Functionality

Recurring transactions allow users to schedule repeating income or expenses based on a custom frequency (e.g., every 1 month, every 2 weeks). Each time the app is launched, it performs a check to see if any recurring transactions are due. If so, it presents the user with a notification and a list of "pending" transactions. The user manually reviews each one, choosing to either approve it (which adds the transaction to the history) or skip it. Users are always kept aware of each transaction and the app never adds unexpected automatic entries.

## Edge Cases
1. **Multiple Missed Cycles**: If the user doesn't open the app for a long time (e.g., 3 months), a recurring transaction could be overdue multiple times. The app uses a `while` loop to catch up, generating a distinct, independent pending instance for every single missed interval. To prevent skipping cycles, the user is forced to process the transactions in chronological order.
2. **Short-Month Date Clamping**: If a 1-month recurring transaction is scheduled on January 31st, the app calculates the next date as February 28th (clamping to the end of the shorter month).
3. **Mid-Cycle Editing**: If a user edits the start date and/or frequency of an existing template (e.g., changing it from 1 month to 2 weeks), the system performs a recalculation, starting from the template's `startDate` and stepping forward by the new interval until it clears the date of the most recently approved transaction in the ledger. This follows the assumption that a user will rarely update a template to create past transactions, but to set a new schedule going forward.

## Technical Implmentation
- `RecurringProcessingService` parses the database for overdue transactions, calculates future due dates, and handles the logic of approving/rejecting instances. It uses `DataService` for low-level database operations and ` PendingApprovalsDialog` for the interactive modal UI where users sequentially approve or skip due transactions.

# Credit Card Rewards

Users can link expenses to specific credit cards and earn rewards (either Cashback or Points/Miles). To handle edge cases where certain transactions might not be eligible for rewards or the reward amount is slightly off due to rounding, users are allowed to manually edit their reward amounts.

When a user selects a credit card and activates the toggle for rewards, the reward amount field is pre-filled with an amount that is calculated with the reward rate and the expense amount. The user is allowed to type to replace the pre-filled value with any custom value.

Sign-up bonuses and custom statement periods are out of scope.