// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'dart:ui';
///
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

// The M3 sizes are coming from the tokens, but are hand coded,
// as the current token DB does not contain landscape versions.
const Size _calendarPortraitDialogSizeM2 = Size(330.0, 518.0);
const Size _calendarPortraitDialogSizeM3 = Size(360.0, 568.0);
const Size _calendarLandscapeDialogSize = Size(496.0, 346.0);
const Size _inputPortraitDialogSizeM2 = Size(330.0, 270.0);
const Size _inputPortraitDialogSizeM3 = Size(328.0, 270.0);
const Size _inputLandscapeDialogSize = Size(496, 160.0);
const Size _inputRangeLandscapeDialogSize = Size(496, 164.0);
const Duration _dialogSizeAnimationDuration = Duration(milliseconds: 200);
const double _inputFormPortraitHeight = 98.0;
const double _inputFormLandscapeHeight = 108.0;

// 3.0 is the maximum scale factor on mobile phones. As of 07/30/24, iOS goes up
// to a max of 3.0 text scale factor, and Android goes up to 2.0. This is the
// default used for non-range date pickers. This default is changed to a lower
// value at different parts of the date pickers depending on content, and device
// orientation.
const double _kMaxTextScaleFactor = 3.0;

// The max scale factor for the date range pickers.
const double _kMaxRangeTextScaleFactor = 1.3;

// The max text scale factor for the header. This is lower than the default as
// the title text already starts at a large size.
const double _kMaxHeaderTextScaleFactor = 1.6;

// The entry button shares a line with the header text, so there is less room to
// scale up.
const double _kMaxHeaderWithEntryTextScaleFactor = 1.4;

const double _kMaxHelpPortraitTextScaleFactor = 1.6;
const double _kMaxHelpLandscapeTextScaleFactor = 1.4;

// 14 is a common font size used to compute the effective text scale.
const double _fontSizeToScale = 14.0;

/// Shows a dialog containing a Material Design date picker.
///
/// The returned [Future] resolves to the date selected by the user when the
/// user confirms the dialog. If the user cancels the dialog, null is returned.
///
/// When the date picker is first displayed, if [initialDate] is not null, it
/// will show the month of [initialDate], with [initialDate] selected. Otherwise
/// it will show the [currentDate]'s month.
///
/// The [firstDate] is the earliest allowable date. The [lastDate] is the latest
/// allowable date. If [initialDate] is not null, it must either fall between
/// these dates, or be equal to one of them. For each of these [DateTime]
/// parameters, only their dates are considered. Their time fields are ignored.
/// They must all be non-null.
///
/// The [currentDate] represents the current day (i.e. today). This
/// date will be highlighted in the day grid. If null, the date of
/// [DateTime.now] will be used.
///
/// An optional [initialEntryMode] argument can be used to display the date
/// picker in the [DatePickerEntryMode.calendar] (a calendar month grid)
/// or [DatePickerEntryMode.input] (a text input field) mode.
/// It defaults to [DatePickerEntryMode.calendar].
///
/// {@template flutter.material.date_picker.switchToInputEntryModeIcon}
/// An optional [switchToInputEntryModeIcon] argument can be used to
/// display a custom Icon in the corner of the dialog
/// when [DatePickerEntryMode] is [DatePickerEntryMode.calendar]. Clicking on
/// icon changes the [DatePickerEntryMode] to [DatePickerEntryMode.input].
/// If null, `Icon(useMaterial3 ? Icons.edit_outlined : Icons.edit)` is used.
/// {@endtemplate}
///
/// {@template flutter.material.date_picker.switchToCalendarEntryModeIcon}
/// An optional [switchToCalendarEntryModeIcon] argument can be used to
/// display a custom Icon in the corner of the dialog
/// when [DatePickerEntryMode] is [DatePickerEntryMode.input]. Clicking on
/// icon changes the [DatePickerEntryMode] to [DatePickerEntryMode.calendar].
/// If null, `Icon(Icons.calendar_today)` is used.
/// {@endtemplate}
///
/// An optional [selectableDayPredicate] function can be passed in to only allow
/// certain days for selection. If provided, only the days that
/// [selectableDayPredicate] returns true for will be selectable. For example,
/// this can be used to only allow weekdays for selection. If provided, it must
/// return true for [initialDate].
///
/// {@macro flutter.material.calendar_date_picker.calendarDelegate}
///
/// The following optional string parameters allow you to override the default
/// text used for various parts of the dialog:
///
///   * [helpText], label displayed at the top of the dialog.
///   * [cancelText], label on the cancel button.
///   * [confirmText], label on the ok button.
///   * [errorFormatText], message used when the input text isn't in a proper date format.
///   * [errorInvalidText], message used when the input text isn't a selectable date.
///   * [fieldHintText], text used to prompt the user when no text has been entered in the field.
///   * [fieldLabelText], label for the date text input field.
///
/// An optional [locale] argument can be used to set the locale for the date
/// picker. It defaults to the ambient locale provided by [Localizations].
///
/// An optional [textDirection] argument can be used to set the text direction
/// ([TextDirection.ltr] or [TextDirection.rtl]) for the date picker. It
/// defaults to the ambient text direction provided by [Directionality]. If both
/// [locale] and [textDirection] are non-null, [textDirection] overrides the
/// direction chosen for the [locale].
///
/// The [context], [barrierDismissible], [barrierColor], [barrierLabel],
/// [useRootNavigator] and [routeSettings] arguments are passed to [showDialog],
/// the documentation for which discusses how it is used.
///
/// The [builder] parameter can be used to wrap the dialog widget
/// to add inherited widgets like [Theme].
///
/// An optional [initialDatePickerMode] argument can be used to have the
/// calendar date picker initially appear in the [DatePickerMode.year] or
/// [DatePickerMode.day] mode. It defaults to [DatePickerMode.day].
///
/// {@macro flutter.widgets.RawDialogRoute}
///
/// {@tool dartpad}
/// This sample demonstrates how to create a basic date picker.
/// Tapping the button displays a date picker which returns the selected date.
///
/// ** See code in examples/api/lib/material/date_picker/show_date_picker.1.dart **
/// {@end-tool}
///
/// ### State Restoration
///
/// Using this method will not enable state restoration for the date picker.
/// In order to enable state restoration for a date picker, use
/// [Navigator.restorablePush] or [Navigator.restorablePushNamed] with
/// [DatePickerDialog].
///
/// For more information about state restoration, see [RestorationManager].
///
/// {@macro flutter.widgets.RestorationManager}
///
/// {@tool dartpad}
/// This sample demonstrates how to create a restorable Material date picker.
/// This is accomplished by enabling state restoration by specifying
/// [MaterialApp.restorationScopeId] and using [Navigator.restorablePush] to
/// push [DatePickerDialog] when the button is tapped.
///
/// ** See code in examples/api/lib/material/date_picker/show_date_picker.0.dart **
/// {@end-tool}
///
/// See also:
///
///  * [showDateRangePicker], which shows a Material Design date range picker
///    used to select a range of dates.
///  * [CalendarDatePicker], which provides the calendar grid used by the date picker dialog.
///  * [InputDatePickerFormField], which provides a text input field for entering dates.
///  * [DisplayFeatureSubScreen], which documents the specifics of how
///    [DisplayFeature]s can split the screen into sub-screens.
///  * [showTimePicker], which shows a dialog that contains a Material Design time picker.
Future<DateTime?> showDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? currentDate,
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  SelectableDayPredicate? selectableDayPredicate,
  String? helpText,
  String? cancelText,
  String? confirmText,
  Locale? locale,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  TextDirection? textDirection,
  TransitionBuilder? builder,
  DatePickerMode initialDatePickerMode = DatePickerMode.day,
  String? errorFormatText,
  String? errorInvalidText,
  String? fieldHintText,
  String? fieldLabelText,
  TextInputType? keyboardType,
  Offset? anchorPoint,
  final ValueChanged<DatePickerEntryMode>? onDatePickerModeChange,
  final Icon? switchToInputEntryModeIcon,
  final Icon? switchToCalendarEntryModeIcon,
  final CalendarDelegate<DateTime> calendarDelegate =
      const GregorianCalendarDelegate(),
}) async {
  initialDate = initialDate == null
      ? null
      : calendarDelegate.dateOnly(initialDate);
  firstDate = calendarDelegate.dateOnly(firstDate);
  lastDate = calendarDelegate.dateOnly(lastDate);
  assert(
    !lastDate.isBefore(firstDate),
    'lastDate $lastDate must be on or after firstDate $firstDate.',
  );
  assert(
    initialDate == null || !initialDate.isBefore(firstDate),
    'initialDate $initialDate must be on or after firstDate $firstDate.',
  );
  assert(
    initialDate == null || !initialDate.isAfter(lastDate),
    'initialDate $initialDate must be on or before lastDate $lastDate.',
  );
  assert(
    selectableDayPredicate == null ||
        initialDate == null ||
        selectableDayPredicate(initialDate),
    'Provided initialDate $initialDate must satisfy provided selectableDayPredicate.',
  );
  assert(debugCheckHasMaterialLocalizations(context));

  Widget dialog = DatePickerDialog(
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    currentDate: currentDate,
    initialEntryMode: initialEntryMode,
    selectableDayPredicate: selectableDayPredicate,
    helpText: helpText,
    cancelText: cancelText,
    confirmText: confirmText,
    initialCalendarMode: initialDatePickerMode,
    errorFormatText: errorFormatText,
    errorInvalidText: errorInvalidText,
    fieldHintText: fieldHintText,
    fieldLabelText: fieldLabelText,
    keyboardType: keyboardType,
    onDatePickerModeChange: onDatePickerModeChange,
    switchToInputEntryModeIcon: switchToInputEntryModeIcon,
    switchToCalendarEntryModeIcon: switchToCalendarEntryModeIcon,
    calendarDelegate: calendarDelegate,
  );

  if (textDirection != null) {
    dialog = Directionality(textDirection: textDirection, child: dialog);
  }

  if (locale != null) {
    dialog = Localizations.override(
      context: context,
      locale: locale,
      child: dialog,
    );
  } else {
    final DatePickerThemeData datePickerTheme = DatePickerTheme.of(context);
    if (datePickerTheme.locale != null) {
      dialog = Localizations.override(
        context: context,
        locale: datePickerTheme.locale,
        child: dialog,
      );
    }
  }

  return showDialog<DateTime>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    builder: (BuildContext context) {
      return builder == null ? dialog : builder(context, dialog);
    },
    anchorPoint: anchorPoint,
  );
}

/// A Material-style date picker dialog.
///
/// It is used internally by [showDatePicker] or can be directly pushed
/// onto the [Navigator] stack to enable state restoration. See
/// [showDatePicker] for a state restoration app example.
///
/// See also:
///
///  * [showDatePicker], which is a way to display the date picker.
class DatePickerDialog extends StatefulWidget {
  /// A Material-style date picker dialog.
  DatePickerDialog({
    super.key,
    DateTime? initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    this.initialEntryMode = DatePickerEntryMode.calendar,
    this.selectableDayPredicate,
    this.cancelText,
    this.confirmText,
    this.helpText,
    this.initialCalendarMode = DatePickerMode.day,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
    this.keyboardType,
    this.restorationId,
    this.onDatePickerModeChange,
    this.switchToInputEntryModeIcon,
    this.switchToCalendarEntryModeIcon,
    this.insetPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 24.0,
    ),
    this.calendarDelegate = const GregorianCalendarDelegate(),
  }) : initialDate = initialDate == null
           ? null
           : calendarDelegate.dateOnly(initialDate),
       firstDate = calendarDelegate.dateOnly(firstDate),
       lastDate = calendarDelegate.dateOnly(lastDate),
       currentDate = calendarDelegate.dateOnly(
         currentDate ?? calendarDelegate.now(),
       ) {
    assert(
      !this.lastDate.isBefore(this.firstDate),
      'lastDate ${this.lastDate} must be on or after firstDate ${this.firstDate}.',
    );
    assert(
      initialDate == null || !this.initialDate!.isBefore(this.firstDate),
      'initialDate ${this.initialDate} must be on or after firstDate ${this.firstDate}.',
    );
    assert(
      initialDate == null || !this.initialDate!.isAfter(this.lastDate),
      'initialDate ${this.initialDate} must be on or before lastDate ${this.lastDate}.',
    );
    assert(
      selectableDayPredicate == null ||
          initialDate == null ||
          selectableDayPredicate!(this.initialDate!),
      'Provided initialDate ${this.initialDate} must satisfy provided selectableDayPredicate',
    );
  }

  /// The initially selected [DateTime] that the picker should display.
  ///
  /// If this is null, there is no selected date. A date must be selected to
  /// submit the dialog.
  final DateTime? initialDate;

  /// The earliest allowable [DateTime] that the user can select.
  final DateTime firstDate;

  /// The latest allowable [DateTime] that the user can select.
  final DateTime lastDate;

  /// The [DateTime] representing today. It will be highlighted in the day grid.
  final DateTime currentDate;

  /// The initial mode of date entry method for the date picker dialog.
  ///
  /// See [DatePickerEntryMode] for more details on the different data entry
  /// modes available.
  final DatePickerEntryMode initialEntryMode;

  /// Function to provide full control over which [DateTime] can be selected.
  final SelectableDayPredicate? selectableDayPredicate;

  /// The text that is displayed on the cancel button.
  final String? cancelText;

  /// The text that is displayed on the confirm button.
  final String? confirmText;

  /// The text that is displayed at the top of the header.
  ///
  /// This is used to indicate to the user what they are selecting a date for.
  final String? helpText;

  /// The initial display of the calendar picker.
  final DatePickerMode initialCalendarMode;

  /// The error text displayed if the entered date is not in the correct format.
  final String? errorFormatText;

  /// The error text displayed if the date is not valid.
  ///
  /// A date is not valid if it is earlier than [firstDate], later than
  /// [lastDate], or doesn't pass the [selectableDayPredicate].
  final String? errorInvalidText;

  /// The hint text displayed in the [TextField].
  ///
  /// If this is null, it will default to the date format string. For example,
  /// 'mm/dd/yyyy' for en_US.
  final String? fieldHintText;

  /// The label text displayed in the [TextField].
  ///
  /// If this is null, it will default to the words representing the date format
  /// string. For example, 'Month, Day, Year' for en_US.
  final String? fieldLabelText;

  /// {@template flutter.material.datePickerDialog}
  /// The keyboard type of the [TextField].
  ///
  /// If this is null, it will default to [TextInputType.datetime]
  /// {@endtemplate}
  final TextInputType? keyboardType;

  /// Restoration ID to save and restore the state of the [DatePickerDialog].
  ///
  /// If it is non-null, the date picker will persist and restore the
  /// date selected on the dialog.
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  final String? restorationId;

  /// Called when the [DatePickerDialog] is toggled between
  /// [DatePickerEntryMode.calendar],[DatePickerEntryMode.input].
  ///
  /// An example of how this callback might be used is an app that saves the
  /// user's preferred entry mode and uses it to initialize the
  /// `initialEntryMode` parameter the next time the date picker is shown.
  final ValueChanged<DatePickerEntryMode>? onDatePickerModeChange;

  /// {@macro flutter.material.date_picker.switchToInputEntryModeIcon}
  final Icon? switchToInputEntryModeIcon;

  /// {@macro flutter.material.date_picker.switchToCalendarEntryModeIcon}
  final Icon? switchToCalendarEntryModeIcon;

  /// The amount of padding added to [MediaQueryData.viewInsets] on the outside
  /// of the dialog. This defines the minimum space between the screen's edges
  /// and the dialog.
  ///
  /// Defaults to `EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0)`.
  final EdgeInsets insetPadding;

  /// {@macro flutter.material.calendar_date_picker.calendarDelegate}
  final CalendarDelegate<DateTime> calendarDelegate;

  @override
  State<DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<DatePickerDialog>
    with RestorationMixin {
  late final RestorableDateTimeN _selectedDate = RestorableDateTimeN(
    widget.initialDate,
  );
  late final _RestorableDatePickerEntryMode _entryMode =
      _RestorableDatePickerEntryMode(widget.initialEntryMode);
  final _RestorableAutovalidateMode _autovalidateMode =
      _RestorableAutovalidateMode(AutovalidateMode.disabled);

  @override
  void dispose() {
    _selectedDate.dispose();
    _entryMode.dispose();
    _autovalidateMode.dispose();
    super.dispose();
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(_autovalidateMode, 'autovalidateMode');
    registerForRestoration(_entryMode, 'calendar_entry_mode');
  }

  final GlobalKey _calendarPickerKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleOk() {
    if (_entryMode.value == DatePickerEntryMode.input ||
        _entryMode.value == DatePickerEntryMode.inputOnly) {
      final FormState form = _formKey.currentState!;
      if (!form.validate()) {
        setState(() => _autovalidateMode.value = AutovalidateMode.always);
        return;
      }
      form.save();
    }
    Navigator.pop(context, _selectedDate.value);
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOnDatePickerModeChange() {
    widget.onDatePickerModeChange?.call(_entryMode.value);
  }

  void _handleEntryModeToggle() {
    setState(() {
      switch (_entryMode.value) {
        case DatePickerEntryMode.calendar:
          _autovalidateMode.value = AutovalidateMode.disabled;
          _entryMode.value = DatePickerEntryMode.input;
          _handleOnDatePickerModeChange();
        case DatePickerEntryMode.input:
          _formKey.currentState!.save();
          _entryMode.value = DatePickerEntryMode.calendar;
          _handleOnDatePickerModeChange();
        case DatePickerEntryMode.calendarOnly:
        case DatePickerEntryMode.inputOnly:
          assert(false, 'Can not change entry mode from ${_entryMode.value}');
      }
    });
  }

  void _handleDateChanged(DateTime date) {
    setState(() => _selectedDate.value = date);
  }

  Size _dialogSize(BuildContext context) {
    final bool useMaterial3 = Theme.of(context).useMaterial3;
    final bool isCalendar = switch (_entryMode.value) {
      DatePickerEntryMode.calendar || DatePickerEntryMode.calendarOnly => true,
      DatePickerEntryMode.input || DatePickerEntryMode.inputOnly => false,
    };
    final Orientation orientation = MediaQuery.orientationOf(context);

    return switch ((isCalendar, orientation)) {
      (true, Orientation.portrait) when useMaterial3 =>
        _calendarPortraitDialogSizeM3,
      (false, Orientation.portrait) when useMaterial3 =>
        _inputPortraitDialogSizeM3,
      (true, Orientation.portrait) => _calendarPortraitDialogSizeM2,
      (false, Orientation.portrait) => _inputPortraitDialogSizeM2,
      (true, Orientation.landscape) => _calendarLandscapeDialogSize,
      (false, Orientation.landscape) => _inputLandscapeDialogSize,
    };
  }

  static const Map<ShortcutActivator, Intent>
  _formShortcutMap = <ShortcutActivator, Intent>{
    // Pressing enter on the field will move focus to the next field or control.
    SingleActivator(LogicalKeyboardKey.enter): NextFocusIntent(),
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool useMaterial3 = theme.useMaterial3;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final Orientation orientation = MediaQuery.orientationOf(context);
    final isLandscapeOrientation = orientation == Orientation.landscape;
    final DatePickerThemeData datePickerTheme = DatePickerTheme.of(context);
    final DatePickerThemeData defaults = DatePickerTheme.defaults(context);
    final TextTheme textTheme = theme.textTheme;

    // There's no M3 spec for a landscape layout input (not calendar)
    // date picker. To ensure that the date displayed in the input
    // date picker's header fits in landscape mode, we override the M3
    // default here.
    TextStyle? headlineStyle;
    if (useMaterial3) {
      headlineStyle =
          datePickerTheme.headerHeadlineStyle ?? defaults.headerHeadlineStyle;
      switch (_entryMode.value) {
        case DatePickerEntryMode.input:
        case DatePickerEntryMode.inputOnly:
          if (orientation == Orientation.landscape) {
            headlineStyle = textTheme.headlineSmall;
          }
        case DatePickerEntryMode.calendar:
        case DatePickerEntryMode.calendarOnly:
        // M3 default is OK.
      }
    } else {
      headlineStyle = isLandscapeOrientation
          ? textTheme.headlineSmall
          : textTheme.headlineMedium;
    }
    final Color? headerForegroundColor =
        datePickerTheme.headerForegroundColor ?? defaults.headerForegroundColor;
    headlineStyle = headlineStyle?.copyWith(color: headerForegroundColor);

    final Widget actions = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52.0),
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: isLandscapeOrientation ? 1.6 : _kMaxTextScaleFactor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: OverflowBar(
              spacing: 8,
              children: <Widget>[
                TextButton(
                  style:
                      datePickerTheme.cancelButtonStyle ??
                      defaults.cancelButtonStyle,
                  onPressed: _handleCancel,
                  child: Text(
                    widget.cancelText ??
                        (useMaterial3
                            ? localizations.cancelButtonLabel
                            : localizations.cancelButtonLabel.toUpperCase()),
                  ),
                ),
                TextButton(
                  style:
                      datePickerTheme.confirmButtonStyle ??
                      defaults.confirmButtonStyle,
                  onPressed: _handleOk,
                  child: Text(
                    widget.confirmText ?? localizations.okButtonLabel,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    CalendarDatePicker calendarDatePicker() {
      return CalendarDatePicker(
        calendarDelegate: widget.calendarDelegate,
        key: _calendarPickerKey,
        initialDate: _selectedDate.value,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        currentDate: widget.currentDate,
        onDateChanged: _handleDateChanged,
        selectableDayPredicate: widget.selectableDayPredicate,
        initialCalendarMode: widget.initialCalendarMode,
      );
    }

    Form inputDatePicker() {
      return Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode.value,
        child: SizedBox(
          height: orientation == Orientation.portrait
              ? _inputFormPortraitHeight
              : _inputFormLandscapeHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Shortcuts(
              shortcuts: _formShortcutMap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: MediaQuery.withClampedTextScaling(
                      maxScaleFactor: 2.0,
                      child: InputDatePickerFormField(
                        calendarDelegate: widget.calendarDelegate,
                        initialDate: _selectedDate.value,
                        firstDate: widget.firstDate,
                        lastDate: widget.lastDate,
                        onDateSubmitted: _handleDateChanged,
                        onDateSaved: _handleDateChanged,
                        selectableDayPredicate: widget.selectableDayPredicate,
                        errorFormatText: widget.errorFormatText,
                        errorInvalidText: widget.errorInvalidText,
                        fieldHintText: widget.fieldHintText,
                        fieldLabelText: widget.fieldLabelText,
                        keyboardType: widget.keyboardType,
                        autofocus: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final Widget picker;
    final Widget? entryModeButton;
    switch (_entryMode.value) {
      case DatePickerEntryMode.calendar:
        picker = calendarDatePicker();
        entryModeButton = IconButton(
          icon:
              widget.switchToInputEntryModeIcon ??
              Icon(useMaterial3 ? Icons.edit_outlined : Icons.edit),
          color: headerForegroundColor,
          tooltip: localizations.inputDateModeButtonLabel,
          onPressed: _handleEntryModeToggle,
        );

      case DatePickerEntryMode.calendarOnly:
        picker = calendarDatePicker();
        entryModeButton = null;

      case DatePickerEntryMode.input:
        picker = inputDatePicker();
        entryModeButton = IconButton(
          icon:
              widget.switchToCalendarEntryModeIcon ??
              const Icon(Icons.calendar_today),
          color: headerForegroundColor,
          tooltip: localizations.calendarModeButtonLabel,
          onPressed: _handleEntryModeToggle,
        );

      case DatePickerEntryMode.inputOnly:
        picker = inputDatePicker();
        entryModeButton = null;
    }

    final Widget header = _DatePickerHeader(
      helpText:
          widget.helpText ??
          (useMaterial3
              ? localizations.datePickerHelpText
              : localizations.datePickerHelpText.toUpperCase()),
      titleText: _selectedDate.value == null
          ? ''
          : widget.calendarDelegate.formatMediumDate(
              _selectedDate.value!,
              localizations,
            ),
      titleStyle: headlineStyle,
      orientation: orientation,
      isShort: orientation == Orientation.landscape,
      entryModeButton: entryModeButton,
    );

    // Constrain the textScaleFactor to the largest supported value to prevent
    // layout issues.
    final double textScaleFactor =
        MediaQuery.textScalerOf(
          context,
        ).clamp(maxScaleFactor: _kMaxTextScaleFactor).scale(_fontSizeToScale) /
        _fontSizeToScale;
    final Size dialogSize = _dialogSize(context) * textScaleFactor;
    final DialogThemeData dialogTheme = theme.dialogTheme;
    return Dialog(
      backgroundColor:
          datePickerTheme.backgroundColor ?? defaults.backgroundColor,
      elevation: useMaterial3
          ? datePickerTheme.elevation ?? defaults.elevation!
          : datePickerTheme.elevation ?? dialogTheme.elevation ?? 24,
      shadowColor: datePickerTheme.shadowColor ?? defaults.shadowColor,
      surfaceTintColor:
          datePickerTheme.surfaceTintColor ?? defaults.surfaceTintColor,
      shape: useMaterial3
          ? datePickerTheme.shape ?? defaults.shape
          : datePickerTheme.shape ?? dialogTheme.shape ?? defaults.shape,
      insetPadding: widget.insetPadding,
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        width: dialogSize.width,
        height: dialogSize.height,
        duration: _dialogSizeAnimationDuration,
        curve: Curves.easeIn,
        child: MediaQuery.withClampedTextScaling(
          // Constrain the textScaleFactor to the largest supported value to prevent
          // layout issues.
          maxScaleFactor: _kMaxTextScaleFactor,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Size portraitDialogSize = useMaterial3
                  ? _inputPortraitDialogSizeM3
                  : _inputPortraitDialogSizeM2;
              // Make sure the portrait dialog can fit the contents comfortably when
              // resized from the landscape dialog.
              final bool isFullyPortrait =
                  constraints.maxHeight >=
                  math.min(dialogSize.height, portraitDialogSize.height);

              switch (orientation) {
                case Orientation.portrait:
                  final bool isInputMode =
                      _entryMode.value == DatePickerEntryMode.inputOnly ||
                      _entryMode.value == DatePickerEntryMode.input;
                  // When the portrait dialog does not fit vertically, hide the header when the entry mode
                  // is input, or hide the picker when the entry mode is not input.
                  final bool showHeader = isFullyPortrait || !isInputMode;
                  final bool showPicker = isFullyPortrait || isInputMode;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (showHeader) header,
                      if (useMaterial3)
                        Divider(height: 0, color: datePickerTheme.dividerColor),
                      if (showPicker) ...<Widget>[
                        Expanded(child: picker),
                        actions,
                      ],
                    ],
                  );
                case Orientation.landscape:
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      header,
                      if (useMaterial3)
                        VerticalDivider(
                          width: 0,
                          color: datePickerTheme.dividerColor,
                        ),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(child: picker),
                            actions,
                          ],
                        ),
                      ),
                    ],
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}

// A restorable [DatePickerEntryMode] value.
//
// This serializes each entry as a unique `int` value.
class _RestorableDatePickerEntryMode
    extends RestorableValue<DatePickerEntryMode> {
  _RestorableDatePickerEntryMode(DatePickerEntryMode defaultValue)
    : _defaultValue = defaultValue;

  final DatePickerEntryMode _defaultValue;

  @override
  DatePickerEntryMode createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(DatePickerEntryMode? oldValue) {
    assert(debugIsSerializableForRestoration(value.index));
    notifyListeners();
  }

  @override
  DatePickerEntryMode fromPrimitives(Object? data) =>
      DatePickerEntryMode.values[data! as int];

  @override
  Object? toPrimitives() => value.index;
}

// A restorable [AutovalidateMode] value.
//
// This serializes each entry as a unique `int` value.
class _RestorableAutovalidateMode extends RestorableValue<AutovalidateMode> {
  _RestorableAutovalidateMode(AutovalidateMode defaultValue)
    : _defaultValue = defaultValue;

  final AutovalidateMode _defaultValue;

  @override
  AutovalidateMode createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(AutovalidateMode? oldValue) {
    assert(debugIsSerializableForRestoration(value.index));
    notifyListeners();
  }

  @override
  AutovalidateMode fromPrimitives(Object? data) =>
      AutovalidateMode.values[data! as int];

  @override
  Object? toPrimitives() => value.index;
}

/// Re-usable widget that displays the selected date (in large font) and the
/// help text above it.
///
/// These types include:
///
/// * Single Date picker with calendar mode.
/// * Single Date picker with text input mode.
/// * Date Range picker with text input mode.
class _DatePickerHeader extends StatelessWidget {
  /// Creates a header for use in a date picker dialog.
  const _DatePickerHeader({
    required this.helpText,
    required this.titleText,
    required this.titleStyle,
    required this.orientation,
    this.isShort = false,
    this.entryModeButton,
  });

  static const double _datePickerHeaderLandscapeWidth = 152.0;
  static const double _datePickerHeaderPortraitHeight = 120.0;
  static const double _headerPaddingLandscape = 16.0;

  /// The text that is displayed at the top of the header.
  ///
  /// This is used to indicate to the user what they are selecting a date for.
  final String helpText;

  /// The text that is displayed at the center of the header.
  final String titleText;

  /// The [TextStyle] that the title text is displayed with.
  final TextStyle? titleStyle;

  /// The orientation is used to decide how to layout its children.
  final Orientation orientation;

  /// Indicates the header is being displayed in a shorter/narrower context.
  ///
  /// This will be used to tighten up the space between the help text and date
  /// text if `true`. Additionally, it will use a smaller typography style if
  /// `true`.
  ///
  /// This is necessary for displaying the manual input mode in
  /// landscape orientation, in order to account for the keyboard height.
  final bool isShort;

  final Widget? entryModeButton;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DatePickerThemeData datePickerTheme = DatePickerTheme.of(context);
    final DatePickerThemeData defaults = DatePickerTheme.defaults(context);
    final Color? backgroundColor =
        datePickerTheme.headerBackgroundColor ?? defaults.headerBackgroundColor;
    final Color? foregroundColor =
        datePickerTheme.headerForegroundColor ?? defaults.headerForegroundColor;
    final TextStyle? helpStyle =
        (datePickerTheme.headerHelpStyle ?? defaults.headerHelpStyle)?.copyWith(
          color: foregroundColor,
        );
    final double currentScale =
        MediaQuery.textScalerOf(context).scale(_fontSizeToScale) /
        _fontSizeToScale;
    final double maxHeaderTextScaleFactor = math.min(
      currentScale,
      entryModeButton != null
          ? _kMaxHeaderWithEntryTextScaleFactor
          : _kMaxHeaderTextScaleFactor,
    );
    final double textScaleFactor =
        MediaQuery.textScalerOf(context)
            .clamp(maxScaleFactor: maxHeaderTextScaleFactor)
            .scale(_fontSizeToScale) /
        _fontSizeToScale;
    final double scaledFontSize = MediaQuery.textScalerOf(
      context,
    ).scale(titleStyle?.fontSize ?? 32);
    final headerScaleFactor = textScaleFactor > 1 ? textScaleFactor : 1.0;

    final help = Text(
      helpText,
      style: helpStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textScaler: MediaQuery.textScalerOf(context).clamp(
        maxScaleFactor: math.min(
          textScaleFactor,
          orientation == Orientation.portrait
              ? _kMaxHelpPortraitTextScaleFactor
              : _kMaxHelpLandscapeTextScaleFactor,
        ),
      ),
    );
    final title = Text(
      titleText,
      semanticsLabel: titleText,
      style: titleStyle,
      maxLines: orientation == Orientation.portrait
          ? (scaledFontSize > 70 ? 2 : 1)
          : scaledFontSize > 40
          ? 3
          : 2,
      overflow: TextOverflow.ellipsis,
      textScaler: MediaQuery.textScalerOf(
        context,
      ).clamp(maxScaleFactor: textScaleFactor),
    );

    final double fontScaleAdjustedHeaderHeight = headerScaleFactor > 1.3
        ? headerScaleFactor - 0.2
        : 1.0;

    switch (orientation) {
      case Orientation.portrait:
        return Semantics(
          container: true,
          child: SizedBox(
            height:
                _datePickerHeaderPortraitHeight * fontScaleAdjustedHeaderHeight,
            child: Material(
              color: backgroundColor,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 24,
                  end: 12,
                  bottom: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 16),
                    help,
                    const Flexible(child: SizedBox(height: 38)),
                    Row(
                      children: <Widget>[
                        Expanded(child: title),
                        if (entryModeButton != null)
                          Semantics(container: true, child: entryModeButton),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      case Orientation.landscape:
        return Semantics(
          container: true,
          child: SizedBox(
            width: _datePickerHeaderLandscapeWidth,
            child: Material(
              color: backgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _headerPaddingLandscape,
                    ),
                    child: help,
                  ),
                  SizedBox(height: isShort ? 16 : 56),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _headerPaddingLandscape,
                      ),
                      child: title,
                    ),
                  ),
                  if (entryModeButton != null)
                    Padding(
                      padding: theme.useMaterial3
                          // TODO(TahaTesser): This is an eye-balled M3 entry mode button padding
                          // from https://m3.material.io/components/date-pickers/specs#c16c142b-4706-47f3-9400-3cde654b9aa8.
                          // Update this value to use tokens when available.
                          ? const EdgeInsetsDirectional.only(
                              start: 8.0,
                              end: 4.0,
                              bottom: 6.0,
                            )
                          : const EdgeInsets.symmetric(horizontal: 4),
                      child: Semantics(container: true, child: entryModeButton),
                    ),
                ],
              ),
            ),
          ),
        );
    }
  }
}

/// Signature for predicating enabled dates in date range pickers.
///
/// The [selectedStartDay] and [selectedEndDay] are the currently selected start
/// and end dates of a date range, which conditionally enables or disables each
/// date in the picker based on the user selection. (Example: in a hostel's room
/// selection, you are not able to select the end date after the next
/// non-selectable day).
///
/// See [showDateRangePicker], which has a [SelectableDayForRangePredicate]
/// parameter used to specify allowable days in the date range picker.
typedef SelectableDayForRangePredicate =
    bool Function(
      DateTime day,
      DateTime? selectedStartDay,
      DateTime? selectedEndDay,
    );

/// A booked date range with display information.
class BookedDateRange {
  const BookedDateRange({
    required this.range,
    required this.bookedBy,
    this.guestCount,
    this.bookingId,
    this.avatarUrl,
  });

  /// Inclusive date range that is booked.
  final DateTimeRange range;

  /// Display name for who booked the date range.
  final String bookedBy;

  /// Number of guests in the booking.
  final int? guestCount;

  /// Booking reference/id.
  final String? bookingId;

  /// Optional avatar URL for the guest.
  final String? avatarUrl;

  BookedDateRange normalized(CalendarDelegate<DateTime> calendarDelegate) {
    return BookedDateRange(
      range: calendarDelegate.datesOnly(range),
      bookedBy: bookedBy,
      guestCount: guestCount,
      bookingId: bookingId,
      avatarUrl: avatarUrl,
    );
  }

  bool contains(DateTime day) {
    return !day.isBefore(range.start) && !day.isAfter(range.end);
  }
}

/// Shows a full screen modal dialog containing a Material Design date range
/// picker.
///
/// The returned [Future] resolves to the [DateTimeRange] selected by the user
/// when the user saves their selection. If the user cancels the dialog, null is
/// returned.
///
/// If [initialDateRange] is non-null, then it will be used as the initially
/// selected date range. If it is provided, `initialDateRange.start` must be
/// before or on `initialDateRange.end`.
///
/// The [firstDate] is the earliest allowable date. The [lastDate] is the latest
/// allowable date.
///
/// If an initial date range is provided, `initialDateRange.start`
/// and `initialDateRange.end` must both fall between or on [firstDate] and
/// [lastDate]. For all of these [DateTime] values, only their dates are
/// considered. Their time fields are ignored.
///
/// The [currentDate] represents the current day (i.e. today). This
/// date will be highlighted in the day grid. If null, the date of
/// `DateTime.now()` will be used.
///
/// An optional [initialEntryMode] argument can be used to display the date
/// picker in the [DatePickerEntryMode.calendar] (a scrollable calendar month
/// grid) or [DatePickerEntryMode.input] (two text input fields) mode.
/// It defaults to [DatePickerEntryMode.calendar].
///
/// {@macro flutter.material.date_picker.switchToInputEntryModeIcon}
///
/// {@macro flutter.material.date_picker.switchToCalendarEntryModeIcon}
///
/// {@macro flutter.material.calendar_date_picker.calendarDelegate}
///
/// The following optional string parameters allow you to override the default
/// text used for various parts of the dialog:
///
///   * [helpText], the label displayed at the top of the dialog.
///   * [cancelText], the label on the cancel button for the text input mode.
///   * [confirmText],the label on the ok button for the text input mode.
///   * [saveText], the label on the save button for the fullscreen calendar
///     mode.
///   * [errorFormatText], the message used when an input text isn't in a proper
///     date format.
///   * [errorInvalidText], the message used when an input text isn't a
///     selectable date.
///   * [errorInvalidRangeText], the message used when the date range is
///     invalid (e.g. start date is after end date).
///   * [fieldStartHintText], the text used to prompt the user when no text has
///     been entered in the start field.
///   * [fieldEndHintText], the text used to prompt the user when no text has
///     been entered in the end field.
///   * [fieldStartLabelText], the label for the start date text input field.
///   * [fieldEndLabelText], the label for the end date text input field.
///
/// An optional [locale] argument can be used to set the locale for the date
/// picker. It defaults to the ambient locale provided by [Localizations].
///
/// An optional [textDirection] argument can be used to set the text direction
/// ([TextDirection.ltr] or [TextDirection.rtl]) for the date picker. It
/// defaults to the ambient text direction provided by [Directionality]. If both
/// [locale] and [textDirection] are non-null, [textDirection] overrides the
/// direction chosen for the [locale].
///
/// The [context], [barrierDismissible], [barrierColor], [barrierLabel],
/// [useRootNavigator] and [routeSettings] arguments are passed to [showDialog],
/// the documentation for which discusses how it is used.
///
/// The [builder] parameter can be used to wrap the dialog widget
/// to add inherited widgets like [Theme].
///
/// {@macro flutter.widgets.RawDialogRoute}
///
/// ### State Restoration
///
/// Using this method will not enable state restoration for the date range picker.
/// In order to enable state restoration for a date range picker, use
/// [Navigator.restorablePush] or [Navigator.restorablePushNamed] with
/// [BookingCalendar].
///
/// For more information about state restoration, see [RestorationManager].
///
/// {@macro flutter.widgets.RestorationManager}
///
/// {@tool dartpad}
/// This sample demonstrates how to create a restorable Material date range picker.
/// This is accomplished by enabling state restoration by specifying
/// [MaterialApp.restorationScopeId] and using [Navigator.restorablePush] to
/// push [BookingCalendar] when the button is tapped.
///
/// ** See code in examples/api/lib/material/date_picker/show_date_range_picker.0.dart **
/// {@end-tool}
///
/// See also:
///
///  * [showDatePicker], which shows a Material Design date picker used to
///    select a single date.
///  * [DateTimeRange], which is used to describe a date range.
///  * [DisplayFeatureSubScreen], which documents the specifics of how
///    [DisplayFeature]s can split the screen into sub-screens.
Future<DateTimeRange?> showDateRangePicker({
  required BuildContext context,
  DateTimeRange? initialDateRange,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? currentDate,
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendarOnly,
  String? helpText,
  String? cancelText,
  String? confirmText,
  String? saveText,
  String? errorFormatText,
  String? errorInvalidText,
  String? errorInvalidRangeText,
  String? fieldStartHintText,
  String? fieldEndHintText,
  String? fieldStartLabelText,
  String? fieldEndLabelText,
  Locale? locale,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  TextDirection? textDirection,
  TransitionBuilder? builder,
  Offset? anchorPoint,
  TextInputType keyboardType = TextInputType.datetime,
  final Icon? switchToInputEntryModeIcon,
  final Icon? switchToCalendarEntryModeIcon,
  SelectableDayForRangePredicate? selectableDayPredicate,
  List<BookedDateRange> bookedDateRanges = const <BookedDateRange>[],
  ValueChanged<BookedDateRange>? onBookedDateTap,
  ValueChanged<DateTime>? onMonthChange,
  String? propertyName,
  CalendarDelegate<DateTime> calendarDelegate =
      const GregorianCalendarDelegate(),
}) async {
  initialDateRange = initialDateRange == null
      ? null
      : calendarDelegate.datesOnly(initialDateRange);
  firstDate = calendarDelegate.dateOnly(firstDate);
  lastDate = calendarDelegate.dateOnly(lastDate);
  assert(
    !lastDate.isBefore(firstDate),
    'lastDate $lastDate must be on or after firstDate $firstDate.',
  );
  assert(
    initialDateRange == null || !initialDateRange.start.isBefore(firstDate),
    "initialDateRange's start date must be on or after firstDate $firstDate.",
  );
  assert(
    initialDateRange == null || !initialDateRange.end.isBefore(firstDate),
    "initialDateRange's end date must be on or after firstDate $firstDate.",
  );
  assert(
    initialDateRange == null || !initialDateRange.start.isAfter(lastDate),
    "initialDateRange's start date must be on or before lastDate $lastDate.",
  );
  assert(
    initialDateRange == null || !initialDateRange.end.isAfter(lastDate),
    "initialDateRange's end date must be on or before lastDate $lastDate.",
  );
  assert(
    initialDateRange == null ||
        selectableDayPredicate == null ||
        selectableDayPredicate(
          initialDateRange.start,
          initialDateRange.start,
          initialDateRange.end,
        ),
    "initialDateRange's start date must be selectable.",
  );
  assert(
    initialDateRange == null ||
        selectableDayPredicate == null ||
        selectableDayPredicate(
          initialDateRange.end,
          initialDateRange.start,
          initialDateRange.end,
        ),
    "initialDateRange's end date must be selectable.",
  );
  currentDate = calendarDelegate.dateOnly(
    currentDate ?? calendarDelegate.now(),
  );
  assert(debugCheckHasMaterialLocalizations(context));

  Widget dialog = BookingCalendar(
    initialDateRange: initialDateRange,
    firstDate: firstDate,
    lastDate: lastDate,
    currentDate: currentDate,
    selectableDayPredicate: selectableDayPredicate,
    initialEntryMode: initialEntryMode,
    helpText: helpText,
    cancelText: cancelText,
    confirmText: confirmText,
    saveText: saveText,
    errorFormatText: errorFormatText,
    errorInvalidText: errorInvalidText,
    errorInvalidRangeText: errorInvalidRangeText,
    fieldStartHintText: fieldStartHintText,
    fieldEndHintText: fieldEndHintText,
    fieldStartLabelText: fieldStartLabelText,
    fieldEndLabelText: fieldEndLabelText,
    keyboardType: keyboardType,
    switchToInputEntryModeIcon: switchToInputEntryModeIcon,
    switchToCalendarEntryModeIcon: switchToCalendarEntryModeIcon,
    calendarDelegate: calendarDelegate,
    bookedDateRanges: bookedDateRanges,
    onBookedDateTap: onBookedDateTap,
    onMonthChange: onMonthChange,
    propertyName: propertyName,
  );

  if (textDirection != null) {
    dialog = Directionality(textDirection: textDirection, child: dialog);
  }

  if (locale != null) {
    dialog = Localizations.override(
      context: context,
      locale: locale,
      child: dialog,
    );
  }

  return showDialog<DateTimeRange>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    useSafeArea: false,
    builder: (BuildContext context) {
      return builder == null ? dialog : builder(context, dialog);
    },
    anchorPoint: anchorPoint,
  );
}

/// A Material-style date range picker dialog.
///
/// It is used internally by [showDateRangePicker] or can be directly pushed
/// onto the [Navigator] stack to enable state restoration. See
/// [showDateRangePicker] for a state restoration app example.
///
/// See also:
///
///  * [showDateRangePicker], which is a way to display the date picker.
class BookingCalendar extends StatefulWidget {
  /// A Material-style date range picker dialog.
  const BookingCalendar({
    super.key,
    this.initialDateRange,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? currentDate,
    this.initialEntryMode = DatePickerEntryMode.calendarOnly,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.saveText,
    this.errorInvalidRangeText,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldStartHintText,
    this.fieldEndHintText,
    this.fieldStartLabelText,
    this.fieldEndLabelText,
    this.keyboardType = TextInputType.datetime,
    this.restorationId,
    this.switchToInputEntryModeIcon,
    this.switchToCalendarEntryModeIcon,
    this.selectableDayPredicate,
    this.bookedDateRanges = const <BookedDateRange>[],
    this.onBookedDateTap,
    this.propertyName,
    this.nightsBookedLabel,
    this.numberOfGuestsLabel,
    this.numberOfBookingsLabel,
    this.onMonthChange,
    this.calendarDelegate = const GregorianCalendarDelegate(),
  }) : _firstDate = firstDate,
       _lastDate = lastDate,
       _currentDate = currentDate;

  /// The date range that the date range picker starts with when it opens.
  ///
  /// If an initial date range is provided, `initialDateRange.start`
  /// and `initialDateRange.end` must both fall between or on [firstDate] and
  /// [lastDate]. For all of these [DateTime] values, only their dates are
  /// considered. Their time fields are ignored.
  ///
  /// If [initialDateRange] is non-null, then it will be used as the initially
  /// selected date range. If it is provided, `initialDateRange.start` must be
  /// before or on `initialDateRange.end`.
  final DateTimeRange? initialDateRange;

  /// The earliest allowable date on the date range.
  ///
  /// If null, defaults to January 1st of the previous year.
  DateTime get firstDate {
    return calendarDelegate.dateOnly(
      _firstDate ?? DateTime(currentDate.year - 1, 1, 1),
    );
  }

  final DateTime? _firstDate;

  /// The latest allowable date on the date range.
  ///
  /// If null, defaults to December 31st two years ahead.
  DateTime get lastDate {
    return calendarDelegate.dateOnly(
      _lastDate ?? DateTime(currentDate.year + 2, 12, 31),
    );
  }

  final DateTime? _lastDate;

  /// The [currentDate] represents the current day (i.e. today).
  ///
  /// This date will be highlighted in the day grid.
  ///
  /// If `null`, the date of `calendarDelegate.now()` will be used.
  DateTime get currentDate {
    return calendarDelegate.dateOnly(_currentDate ?? calendarDelegate.now());
  }

  final DateTime? _currentDate;

  /// The initial date range picker entry mode.
  ///
  /// The date range has two main modes: [DatePickerEntryMode.calendar] (a
  /// scrollable calendar month grid) or [DatePickerEntryMode.input] (two text
  /// input fields) mode.
  ///
  /// It defaults to [DatePickerEntryMode.calendar].
  final DatePickerEntryMode initialEntryMode;

  /// The label on the cancel button for the text input mode.
  ///
  /// If null, the localized value of
  /// [MaterialLocalizations.cancelButtonLabel] is used.
  final String? cancelText;

  /// The label on the "OK" button for the text input mode.
  ///
  /// If null, the localized value of
  /// [MaterialLocalizations.okButtonLabel] is used.
  final String? confirmText;

  /// The label on the save button for the fullscreen calendar mode.
  ///
  /// If null, the localized value of
  /// [MaterialLocalizations.saveButtonLabel] is used.
  final String? saveText;

  /// The label displayed at the top of the dialog.
  ///
  /// If null, the localized value of
  /// [MaterialLocalizations.dateRangePickerHelpText] is used.
  final String? helpText;

  /// The message used when the date range is invalid (e.g. start date is after
  /// end date).
  ///
  /// If null, the localized value of
  /// [MaterialLocalizations.invalidDateRangeLabel] is used.
  final String? errorInvalidRangeText;

  /// The message used when an input text isn't in a proper date format.
  ///
  /// If null, the localized value of
  /// [MaterialLocalizations.invalidDateFormatLabel] is used.
  final String? errorFormatText;

  /// The message used when an input text isn't a selectable date.
  ///
  /// If null, the localized value of
  /// [MaterialLocalizations.dateOutOfRangeLabel] is used.
  final String? errorInvalidText;

  /// The text used to prompt the user when no text has been entered in the
  /// start field.
  ///
  /// If null, the localized value of
  /// [MaterialLocalizations.dateHelpText] is used.
  final String? fieldStartHintText;

  /// The text used to prompt the user when no text has been entered in the
  /// end field.
  ///
  /// If null, the localized value of [MaterialLocalizations.dateHelpText] is
  /// used.
  final String? fieldEndHintText;

  /// The label for the start date text input field.
  ///
  /// If null, the localized value of [MaterialLocalizatioRns.dateRangeStartLabel]
  /// is used.
  final String? fieldStartLabelText;

  /// The label for the end date text input field.
  ///
  /// If null, the localized value of [MaterialLocalizations.dateRangeEndLabel]
  /// is used.
  final String? fieldEndLabelText;

  /// {@macro flutter.material.datePickerDialog}
  final TextInputType keyboardType;

  /// Restoration ID to save and restore the state of the [BookingCalendar].
  ///
  /// If it is non-null, the date range picker will persist and restore the
  /// date range selected on the dialog.
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  final String? restorationId;

  /// {@macro flutter.material.date_picker.switchToInputEntryModeIcon}
  final Icon? switchToInputEntryModeIcon;

  /// {@macro flutter.material.date_picker.switchToCalendarEntryModeIcon}
  final Icon? switchToCalendarEntryModeIcon;

  /// Function to provide full control over which [DateTime] can be selected.
  final SelectableDayForRangePredicate? selectableDayPredicate;

  /// Booked ranges that should be highlighted in the calendar.
  final List<BookedDateRange> bookedDateRanges;

  /// Called when a booked day is tapped.
  final ValueChanged<BookedDateRange>? onBookedDateTap;

  /// Label shown below the header help text.
  final String? propertyName;

  /// Label shown for the total nights metric in the header.
  final String? nightsBookedLabel;

  /// Label shown for the guest-count metric in the header.
  final String? numberOfGuestsLabel;

  /// Label shown for the bookings-count metric in the header.
  final String? numberOfBookingsLabel;

  /// Called when the displayed month changes.
  ///
  /// The callback receives the first day of the newly displayed month.
  final ValueChanged<DateTime>? onMonthChange;

  /// {@macro flutter.material.calendar_date_picker.calendarDelegate}
  final CalendarDelegate<DateTime> calendarDelegate;

  @override
  State<BookingCalendar> createState() => _BookingCalendarState();
}

class _BookingCalendarState extends State<BookingCalendar>
    with RestorationMixin {
  late final _RestorableDatePickerEntryMode _entryMode =
      _RestorableDatePickerEntryMode(widget.initialEntryMode);
  final GlobalKey _calendarPickerKey = GlobalKey();

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_entryMode, 'entry_mode');
  }

  @override
  void dispose() {
    _entryMode.dispose();
    super.dispose();
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleBookedDateTap(BookedDateRange booking) {
    if (widget.onBookedDateTap != null) {
      widget.onBookedDateTap!(booking);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext bottomSheetContext) {
        final MaterialLocalizations localizations = MaterialLocalizations.of(
          bottomSheetContext,
        );
        final String startDate = widget.calendarDelegate.formatMediumDate(
          booking.range.start,
          localizations,
        );
        final String endDate = widget.calendarDelegate.formatMediumDate(
          booking.range.end,
          localizations,
        );
        final String dateText =
            widget.calendarDelegate.isSameDay(
              booking.range.start,
              booking.range.end,
            )
            ? startDate
            : '$startDate - $endDate';

        final String initials = booking.bookedBy
            .trim()
            .split(RegExp(r'\s+'))
            .where((String part) => part.isNotEmpty)
            .take(2)
            .map((String part) => part[0].toUpperCase())
            .join();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 24,
                      foregroundImage:
                          booking.avatarUrl != null &&
                              booking.avatarUrl!.isNotEmpty
                          ? NetworkImage(booking.avatarUrl!)
                          : null,
                      child: Text(initials.isEmpty ? '?' : initials),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            booking.bookedBy,
                            style: Theme.of(
                              bottomSheetContext,
                            ).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateText,
                            style: Theme.of(
                              bottomSheetContext,
                            ).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (booking.bookingId != null && booking.bookingId!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text('Booking ID: ${booking.bookingId}'),
                  ),
                if (booking.guestCount != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Guests: ${booking.guestCount}'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool useMaterial3 = theme.useMaterial3;
    final Orientation orientation = MediaQuery.orientationOf(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final DatePickerThemeData datePickerTheme = DatePickerTheme.of(context);
    final DatePickerThemeData defaults = DatePickerTheme.defaults(context);
    final List<BookedDateRange> normalizedBookedRanges = widget.bookedDateRanges
        .map(
          (BookedDateRange booking) =>
              booking.normalized(widget.calendarDelegate),
        )
        .toList(growable: false);

    final Widget contents;
    final Size size;
    final double? elevation;
    final Color? shadowColor;
    final Color? surfaceTintColor;
    final ShapeBorder? shape;
    final EdgeInsets insetPadding;
    switch (_entryMode.value) {
      case DatePickerEntryMode.calendar:
      case DatePickerEntryMode.calendarOnly:
        contents = _CalendarRangePickerDialog(
          key: _calendarPickerKey,
          calendarDelegate: widget.calendarDelegate,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          currentDate: widget.currentDate,
          onCancel: _handleCancel,
          bookedDateRanges: normalizedBookedRanges,
          onBookedDateTap: _handleBookedDateTap,
          propertyName: widget.propertyName ?? 'The property name',
          nightsBookedLabel: widget.nightsBookedLabel ?? 'Nights booked',
          numberOfGuestsLabel: widget.numberOfGuestsLabel ?? 'No. of guests',
          numberOfBookingsLabel:
              widget.numberOfBookingsLabel ?? 'No. of Bookings',
          onMonthChange: widget.onMonthChange,
          helpText:
              widget.helpText ??
              (useMaterial3
                  ? localizations.dateRangePickerHelpText
                  : localizations.dateRangePickerHelpText.toUpperCase()),
        );
        size = MediaQuery.sizeOf(context);
        insetPadding = EdgeInsets.zero;
        elevation =
            datePickerTheme.rangePickerElevation ??
            defaults.rangePickerElevation!;
        shadowColor =
            datePickerTheme.rangePickerShadowColor ??
            defaults.rangePickerShadowColor!;
        surfaceTintColor =
            datePickerTheme.rangePickerSurfaceTintColor ??
            defaults.rangePickerSurfaceTintColor!;
        shape = datePickerTheme.rangePickerShape ?? defaults.rangePickerShape;

      case DatePickerEntryMode.input:
      case DatePickerEntryMode.inputOnly:
        contents = const SizedBox.shrink();
        final DialogThemeData dialogTheme = theme.dialogTheme;
        size = orientation == Orientation.portrait
            ? (useMaterial3
                  ? _inputPortraitDialogSizeM3
                  : _inputPortraitDialogSizeM2)
            : _inputRangeLandscapeDialogSize;
        elevation = useMaterial3
            ? datePickerTheme.elevation ?? defaults.elevation!
            : datePickerTheme.elevation ?? dialogTheme.elevation ?? 24;
        shadowColor = datePickerTheme.shadowColor ?? defaults.shadowColor;
        surfaceTintColor =
            datePickerTheme.surfaceTintColor ?? defaults.surfaceTintColor;
        shape = useMaterial3
            ? datePickerTheme.shape ?? defaults.shape
            : datePickerTheme.shape ?? dialogTheme.shape ?? defaults.shape;

        insetPadding = const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 24.0,
        );
    }

    return Dialog(
      insetPadding: insetPadding,
      backgroundColor:
          datePickerTheme.backgroundColor ?? defaults.backgroundColor,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        width: size.width,
        height: size.height,
        duration: _dialogSizeAnimationDuration,
        curve: Curves.easeIn,
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: _kMaxRangeTextScaleFactor,
          child: Builder(
            builder: (BuildContext context) {
              return contents;
            },
          ),
        ),
      ),
    );
  }
}

class _CalendarRangePickerDialog extends StatelessWidget {
  const _CalendarRangePickerDialog({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.currentDate,
    required this.onCancel,
    required this.helpText,
    required this.bookedDateRanges,
    required this.onBookedDateTap,
    required this.propertyName,
    required this.nightsBookedLabel,
    required this.numberOfGuestsLabel,
    required this.numberOfBookingsLabel,
    this.onMonthChange,
    required this.calendarDelegate,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? currentDate;
  final VoidCallback? onCancel;
  final String helpText;
  final String propertyName;
  final String nightsBookedLabel;
  final String numberOfGuestsLabel;
  final String numberOfBookingsLabel;
  final ValueChanged<DateTime>? onMonthChange;
  final List<BookedDateRange> bookedDateRanges;
  final ValueChanged<BookedDateRange> onBookedDateTap;
  final CalendarDelegate<DateTime> calendarDelegate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool useMaterial3 = theme.useMaterial3;
    final DatePickerThemeData themeData = DatePickerTheme.of(context);
    final DatePickerThemeData defaults = DatePickerTheme.defaults(context);
    final Color? dialogBackground =
        themeData.rangePickerBackgroundColor ??
        defaults.rangePickerBackgroundColor;
    final Color? headerBackground =
        themeData.rangePickerHeaderBackgroundColor ??
        defaults.rangePickerHeaderBackgroundColor;
    final Color? headerForeground =
        themeData.rangePickerHeaderForegroundColor ??
        defaults.rangePickerHeaderForegroundColor;
    final Color? headerDisabledForeground = headerForeground?.withOpacity(0.38);
    final TextStyle? headlineStyle =
        themeData.rangePickerHeaderHeadlineStyle ??
        defaults.rangePickerHeaderHeadlineStyle;
    final TextStyle? startDateStyle = headlineStyle?.apply(
      color: headerDisabledForeground,
    );
    final iconTheme = IconThemeData(color: headerForeground);
    final int numberOfBookings = bookedDateRanges.length;
    final int numberOfGuests = bookedDateRanges.fold<int>(
      0,
      (int sum, BookedDateRange booking) => sum + (booking.guestCount ?? 0),
    );
    final int nightsBooked = bookedDateRanges.fold<int>(
      0,
      (int sum, BookedDateRange booking) =>
          sum +
          math.max<int>(
            1,
            booking.range.end.difference(booking.range.start).inDays,
          ),
    );

    Widget buildHeaderMetric(String label, int value) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: headerDisabledForeground,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '$value',
              style: theme.textTheme.titleSmall?.copyWith(
                color: headerForeground,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          iconTheme: iconTheme,
          actionsIconTheme: iconTheme,
          elevation: useMaterial3 ? 0 : null,
          scrolledUnderElevation: useMaterial3 ? 0 : null,
          backgroundColor: headerBackground,
          actions: <Widget>[const SizedBox(width: 8)],
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, 130),
            child: Row(
              children: <Widget>[
                SizedBox(width: MediaQuery.widthOf(context) < 360 ? 42 : 72),
                Expanded(
                  child: Semantics(
                    label: propertyName,
                    excludeSemantics: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          propertyName,
                          style:
                              startDateStyle?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ) ??
                              const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            buildHeaderMetric(nightsBookedLabel, nightsBooked),
                            const SizedBox(width: 10),
                            buildHeaderMetric(
                              numberOfGuestsLabel,
                              numberOfGuests,
                            ),
                            const SizedBox(width: 10),
                            buildHeaderMetric(
                              numberOfBookingsLabel,
                              numberOfBookings,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: dialogBackground,
        body: _CalendarDateRangePicker(
          firstDate: firstDate,
          lastDate: lastDate,
          currentDate: currentDate,
          bookedDateRanges: bookedDateRanges,
          onBookedDateTap: onBookedDateTap,
          onMonthChange: onMonthChange,
          calendarDelegate: calendarDelegate,
        ),
      ),
    );
  }
}

const Duration _monthScrollDuration = Duration(milliseconds: 200);

const double _monthItemHeaderHeight = 58.0;
const double _monthItemFooterHeight = 12.0;
const double _monthItemRowHeight = 52.0;
const double _monthItemSpaceBetweenRows = 8.0;
const double _horizontalPadding = 8.0;
const double _maxCalendarContentWidth = 1023.0;

/// Displays a scrollable calendar grid that allows a user to select a range
/// of dates.
class _CalendarDateRangePicker extends StatefulWidget {
  /// Creates a scrollable calendar grid for picking date ranges.
  _CalendarDateRangePicker({
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    required this.bookedDateRanges,
    required this.onBookedDateTap,
    this.onMonthChange,
    required this.calendarDelegate,
  }) : firstDate = calendarDelegate.dateOnly(firstDate),
       lastDate = calendarDelegate.dateOnly(lastDate),
       currentDate = calendarDelegate.dateOnly(
         currentDate ?? calendarDelegate.now(),
       ) {
    assert(
      !this.lastDate.isBefore(this.firstDate),
      'firstDate must be on or before lastDate.',
    );
  }

  /// The earliest allowable [DateTime] that the user can select.
  final DateTime firstDate;

  /// The latest allowable [DateTime] that the user can select.
  final DateTime lastDate;

  /// The [DateTime] representing today. It will be highlighted in the day grid.
  final DateTime currentDate;

  final List<BookedDateRange> bookedDateRanges;

  final ValueChanged<BookedDateRange> onBookedDateTap;

  final ValueChanged<DateTime>? onMonthChange;

  /// {@macro flutter.material.calendar_date_picker.calendarDelegate}
  final CalendarDelegate<DateTime> calendarDelegate;

  @override
  State<_CalendarDateRangePicker> createState() =>
      _CalendarDateRangePickerState();
}

class _CalendarDateRangePickerState extends State<_CalendarDateRangePicker> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final DateTime initialDate = widget.currentDate;
    final DateTime clampedInitialDate = initialDate.isBefore(widget.firstDate)
        ? widget.firstDate
        : (initialDate.isAfter(widget.lastDate)
              ? widget.lastDate
              : initialDate);
    _displayedMonth = widget.calendarDelegate.getMonth(
      clampedInitialDate.year,
      clampedInitialDate.month,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onMonthChange?.call(_displayedMonth);
    });
  }

  @override
  void didUpdateWidget(covariant _CalendarDateRangePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final DateTime firstAllowedMonth = widget.calendarDelegate.getMonth(
      widget.firstDate.year,
      widget.firstDate.month,
    );
    final DateTime lastAllowedMonth = widget.calendarDelegate.getMonth(
      widget.lastDate.year,
      widget.lastDate.month,
    );
    if (_displayedMonth.isBefore(firstAllowedMonth)) {
      _displayedMonth = firstAllowedMonth;
    } else if (_displayedMonth.isAfter(lastAllowedMonth)) {
      _displayedMonth = lastAllowedMonth;
    }
  }

  DateTime get _firstAllowedMonth => widget.calendarDelegate.getMonth(
    widget.firstDate.year,
    widget.firstDate.month,
  );

  DateTime get _lastAllowedMonth => widget.calendarDelegate.getMonth(
    widget.lastDate.year,
    widget.lastDate.month,
  );

  bool get _canGoPrevious => _displayedMonth.isAfter(_firstAllowedMonth);

  bool get _canGoNext => _displayedMonth.isBefore(_lastAllowedMonth);

  String _formatMonthLabel(
    DateTime month,
    MaterialLocalizations localizations,
  ) {
    return widget.calendarDelegate.formatMonthYear(month, localizations);
  }

  void _changeMonth(int delta) {
    final DateTime nextMonth = widget.calendarDelegate.addMonthsToMonthDate(
      _displayedMonth,
      delta,
    );
    if (nextMonth.isBefore(_firstAllowedMonth) ||
        nextMonth.isAfter(_lastAllowedMonth)) {
      return;
    }
    setState(() {
      _displayedMonth = nextMonth;
    });
    widget.onMonthChange?.call(_displayedMonth);
  }

  Widget _buildMonthNavButton({
    required BuildContext context,
    required bool enabled,
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    required bool iconLeading,
  }) {
    final TextStyle? labelStyle = Theme.of(context).textTheme.labelLarge;
    final Widget iconWidget = Icon(icon, size: 18);
    final Widget labelWidget = Flexible(
      child: Text(label, overflow: TextOverflow.ellipsis, style: labelStyle),
    );

    return TextButton(
      onPressed: enabled ? onPressed : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (iconLeading) iconWidget,
          if (iconLeading) const SizedBox(width: 4),
          labelWidget,
          if (!iconLeading) const SizedBox(width: 4),
          if (!iconLeading) iconWidget,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final DateTime previousMonth = widget.calendarDelegate.addMonthsToMonthDate(
      _displayedMonth,
      -1,
    );
    final DateTime nextMonth = widget.calendarDelegate.addMonthsToMonthDate(
      _displayedMonth,
      1,
    );

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _buildMonthNavButton(
                    context: context,
                    enabled: _canGoPrevious,
                    onPressed: () => _changeMonth(-1),
                    label: _formatMonthLabel(previousMonth, localizations),
                    icon: Icons.chevron_left,
                    iconLeading: true,
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _buildMonthNavButton(
                    context: context,
                    enabled: _canGoNext,
                    onPressed: () => _changeMonth(1),
                    label: _formatMonthLabel(nextMonth, localizations),
                    icon: Icons.chevron_right,
                    iconLeading: false,
                  ),
                ),
              ),
            ],
          ),
        ),
        const _DayHeaders(),
        const Divider(height: 0),
        Expanded(
          child: _CalendarKeyboardNavigator(
            calendarDelegate: widget.calendarDelegate,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            initialFocusedDay: widget.currentDate,
            child: _MonthItem(
              calendarDelegate: widget.calendarDelegate,
              currentDate: widget.currentDate,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              displayedMonth: _displayedMonth,
              bookedDateRanges: widget.bookedDateRanges,
              onBookedDateTap: widget.onBookedDateTap,
            ),
          ),
        ),
      ],
    );
  }
}

class _CalendarKeyboardNavigator extends StatefulWidget {
  const _CalendarKeyboardNavigator({
    required this.child,
    required this.firstDate,
    required this.lastDate,
    required this.initialFocusedDay,
    required this.calendarDelegate,
  });

  final Widget child;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime initialFocusedDay;
  final CalendarDelegate<DateTime> calendarDelegate;

  @override
  _CalendarKeyboardNavigatorState createState() =>
      _CalendarKeyboardNavigatorState();
}

class _CalendarKeyboardNavigatorState
    extends State<_CalendarKeyboardNavigator> {
  final Map<ShortcutActivator, Intent> _shortcutMap =
      const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowLeft): DirectionalFocusIntent(
          TraversalDirection.left,
        ),
        SingleActivator(LogicalKeyboardKey.arrowRight): DirectionalFocusIntent(
          TraversalDirection.right,
        ),
        SingleActivator(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(
          TraversalDirection.down,
        ),
        SingleActivator(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(
          TraversalDirection.up,
        ),
      };
  late Map<Type, Action<Intent>> _actionMap;
  late FocusNode _dayGridFocus;
  TraversalDirection? _dayTraversalDirection;
  DateTime? _focusedDay;

  @override
  void initState() {
    super.initState();

    _actionMap = <Type, Action<Intent>>{
      NextFocusIntent: CallbackAction<NextFocusIntent>(
        onInvoke: _handleGridNextFocus,
      ),
      PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
        onInvoke: _handleGridPreviousFocus,
      ),
      DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
        onInvoke: _handleDirectionFocus,
      ),
    };
    _dayGridFocus = FocusNode(debugLabel: 'Day Grid');
  }

  @override
  void dispose() {
    _dayGridFocus.dispose();
    super.dispose();
  }

  void _handleGridFocusChange(bool focused) {
    setState(() {
      if (focused) {
        _focusedDay ??= widget.initialFocusedDay;
      }
    });
  }

  /// Move focus to the next element after the day grid.
  void _handleGridNextFocus(NextFocusIntent intent) {
    _dayGridFocus.requestFocus();
    _dayGridFocus.nextFocus();
  }

  /// Move focus to the previous element before the day grid.
  void _handleGridPreviousFocus(PreviousFocusIntent intent) {
    _dayGridFocus.requestFocus();
    _dayGridFocus.previousFocus();
  }

  /// Move the internal focus date in the direction of the given intent.
  ///
  /// This will attempt to move the focused day to the next selectable day in
  /// the given direction. If the new date is not in the current month, then
  /// the page view will be scrolled to show the new date's month.
  ///
  /// For horizontal directions, it will move forward or backward a day (depending
  /// on the current [TextDirection]). For vertical directions it will move up and
  /// down a week at a time.
  void _handleDirectionFocus(DirectionalFocusIntent intent) {
    assert(_focusedDay != null);
    setState(() {
      final DateTime? nextDate = _nextDateInDirection(
        _focusedDay!,
        intent.direction,
      );
      if (nextDate != null) {
        _focusedDay = nextDate;
        _dayTraversalDirection = intent.direction;
      }
    });
  }

  static const Map<TraversalDirection, int> _directionOffset =
      <TraversalDirection, int>{
        TraversalDirection.up: -DateTime.daysPerWeek,
        TraversalDirection.right: 1,
        TraversalDirection.down: DateTime.daysPerWeek,
        TraversalDirection.left: -1,
      };

  int _dayDirectionOffset(
    TraversalDirection traversalDirection,
    TextDirection textDirection,
  ) {
    // Swap left and right if the text direction if RTL
    if (textDirection == TextDirection.rtl) {
      if (traversalDirection == TraversalDirection.left) {
        traversalDirection = TraversalDirection.right;
      } else if (traversalDirection == TraversalDirection.right) {
        traversalDirection = TraversalDirection.left;
      }
    }
    return _directionOffset[traversalDirection]!;
  }

  DateTime? _nextDateInDirection(DateTime date, TraversalDirection direction) {
    final TextDirection textDirection = Directionality.of(context);
    final DateTime nextDate = widget.calendarDelegate.addDaysToDate(
      date,
      _dayDirectionOffset(direction, textDirection),
    );
    if (!nextDate.isBefore(widget.firstDate) &&
        !nextDate.isAfter(widget.lastDate)) {
      return nextDate;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      shortcuts: _shortcutMap,
      actions: _actionMap,
      focusNode: _dayGridFocus,
      onFocusChange: _handleGridFocusChange,
      child: _FocusedDate(
        calendarDelegate: widget.calendarDelegate,
        date: _dayGridFocus.hasFocus ? _focusedDay : null,
        scrollDirection: _dayGridFocus.hasFocus ? _dayTraversalDirection : null,
        child: widget.child,
      ),
    );
  }
}

/// InheritedWidget indicating what the current focused date is for its children.
// See also: _FocusedDate in calendar_date_picker.dart
class _FocusedDate extends InheritedWidget {
  const _FocusedDate({
    required super.child,
    required this.calendarDelegate,
    this.date,
    this.scrollDirection,
  });

  final CalendarDelegate<DateTime> calendarDelegate;
  final DateTime? date;
  final TraversalDirection? scrollDirection;

  @override
  bool updateShouldNotify(_FocusedDate oldWidget) {
    return !calendarDelegate.isSameDay(date, oldWidget.date) ||
        scrollDirection != oldWidget.scrollDirection;
  }

  static _FocusedDate? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FocusedDate>();
  }
}

class _DayHeaders extends StatelessWidget {
  const _DayHeaders();

  /// Builds widgets showing abbreviated days of week. The first widget in the
  /// returned list corresponds to the first day of week for the current locale.
  ///
  /// Examples:
  ///
  ///     ┌ Sunday is the first day of week in the US (en_US)
  ///     |
  ///     S M T W T F S  ← the returned list contains these widgets
  ///     _ _ _ _ _ 1 2
  ///     3 4 5 6 7 8 9
  ///
  ///     ┌ But it's Monday in the UK (en_GB)
  ///     |
  ///     M T W T F S S  ← the returned list contains these widgets
  ///     _ _ _ _ 1 2 3
  ///     4 5 6 7 8 9 10
  ///
  List<Widget> _getDayHeaders(
    TextStyle headerStyle,
    MaterialLocalizations localizations,
  ) {
    final result = <Widget>[];
    for (
      int i = localizations.firstDayOfWeekIndex;
      result.length < DateTime.daysPerWeek;
      i = (i + 1) % DateTime.daysPerWeek
    ) {
      final String weekday = localizations.narrowWeekdays[i];
      result.add(
        ExcludeSemantics(
          child: Center(child: Text(weekday, style: headerStyle)),
        ),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final TextStyle textStyle = themeData.textTheme.titleSmall!.apply(
      color: colorScheme.onSurface,
    );
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final List<Widget> labels = _getDayHeaders(textStyle, localizations);

    // Add leading and trailing boxes for edges of the custom grid layout.
    labels.insert(0, const SizedBox.shrink());
    labels.add(const SizedBox.shrink());

    return Align(
      alignment: AlignmentDirectional.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxCalendarContentWidth),
        child: SizedBox(
          width: double.infinity,
          height: _monthItemRowHeight,
          child: GridView.custom(
            shrinkWrap: true,
            gridDelegate: _monthItemGridDelegate,
            childrenDelegate: SliverChildListDelegate(
              labels,
              addRepaintBoundaries: false,
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthItemGridDelegate extends SliverGridDelegate {
  const _MonthItemGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double tileWidth = math.max(
      (constraints.crossAxisExtent - 2 * _horizontalPadding) /
          DateTime.daysPerWeek,
      0.0,
    );
    return _MonthSliverGridLayout(
      crossAxisCount: DateTime.daysPerWeek + 2,
      dayChildWidth: tileWidth,
      edgeChildWidth: _horizontalPadding,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_MonthItemGridDelegate oldDelegate) => false;
}

const _MonthItemGridDelegate _monthItemGridDelegate = _MonthItemGridDelegate();

class _MonthSliverGridLayout extends SliverGridLayout {
  /// Creates a layout that uses equally sized and spaced tiles for each day of
  /// the week and an additional edge tile for padding at the start and end of
  /// each row.
  ///
  /// This is necessary to facilitate the painting of the range highlight
  /// correctly.
  const _MonthSliverGridLayout({
    required this.crossAxisCount,
    required this.dayChildWidth,
    required this.edgeChildWidth,
    required this.reverseCrossAxis,
  }) : assert(crossAxisCount > 0),
       assert(dayChildWidth >= 0),
       assert(edgeChildWidth >= 0);

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The width in logical pixels of the day child widgets.
  final double dayChildWidth;

  /// The width in logical pixels of the edge child widgets.
  final double edgeChildWidth;

  /// Whether the children should be placed in the opposite order of increasing
  /// coordinates in the cross axis.
  ///
  /// For example, if the cross axis is horizontal, the children are placed from
  /// left to right when [reverseCrossAxis] is false and from right to left when
  /// [reverseCrossAxis] is true.
  ///
  /// Typically set to the return value of [axisDirectionIsReversed] applied to
  /// the [SliverConstraints.crossAxisDirection].
  final bool reverseCrossAxis;

  /// The number of logical pixels from the leading edge of one row to the
  /// leading edge of the next row.
  double get _rowHeight {
    return _monthItemRowHeight + _monthItemSpaceBetweenRows;
  }

  /// The height in logical pixels of the children widgets.
  double get _childHeight {
    return _monthItemRowHeight;
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    return crossAxisCount * (scrollOffset ~/ _rowHeight);
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    final int mainAxisCount = (scrollOffset / _rowHeight).ceil();
    return math.max(0, crossAxisCount * mainAxisCount - 1);
  }

  double _getCrossAxisOffset(double crossAxisStart, bool isPadding) {
    if (reverseCrossAxis) {
      return ((crossAxisCount - 2) * dayChildWidth + 2 * edgeChildWidth) -
          crossAxisStart -
          (isPadding ? edgeChildWidth : dayChildWidth);
    }
    return crossAxisStart;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final int adjustedIndex = index % crossAxisCount;
    final bool isEdge =
        adjustedIndex == 0 || adjustedIndex == crossAxisCount - 1;
    final double crossAxisStart = math.max(
      0,
      (adjustedIndex - 1) * dayChildWidth + edgeChildWidth,
    );

    return SliverGridGeometry(
      scrollOffset: (index ~/ crossAxisCount) * _rowHeight,
      crossAxisOffset: _getCrossAxisOffset(crossAxisStart, isEdge),
      mainAxisExtent: _childHeight,
      crossAxisExtent: isEdge ? edgeChildWidth : dayChildWidth,
    );
  }

  @override
  double computeMaxScrollOffset(int childCount) {
    assert(childCount >= 0);
    final int mainAxisCount = ((childCount - 1) ~/ crossAxisCount) + 1;
    final double mainAxisSpacing = _rowHeight - _childHeight;
    return _rowHeight * mainAxisCount - mainAxisSpacing;
  }
}

/// Displays the days of a given month and allows choosing a date range.
///
/// The days are arranged in a rectangular grid with one column for each day of
/// the week.
class _MonthItem extends StatefulWidget {
  /// Creates a month item.
  _MonthItem({
    required this.currentDate,
    required this.firstDate,
    required this.lastDate,
    required this.displayedMonth,
    required this.bookedDateRanges,
    required this.onBookedDateTap,
    required this.calendarDelegate,
  }) : assert(!firstDate.isAfter(lastDate));

  /// The current date at the time the picker is displayed.
  final DateTime currentDate;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// The month whose days are displayed by this picker.
  final DateTime displayedMonth;

  final List<BookedDateRange> bookedDateRanges;

  final ValueChanged<BookedDateRange> onBookedDateTap;

  /// {@macro flutter.material.calendar_date_picker.calendarDelegate}
  final CalendarDelegate<DateTime> calendarDelegate;

  @override
  _MonthItemState createState() => _MonthItemState();
}

class _MonthItemState extends State<_MonthItem> {
  static const Color _bookedRangeHighlightColor = Color(0xFFE0CFBB);

  /// List of [FocusNode]s, one for each day of the month.
  late List<FocusNode> _dayFocusNodes;

  @override
  void initState() {
    super.initState();
    final int daysInMonth = widget.calendarDelegate.getDaysInMonth(
      widget.displayedMonth.year,
      widget.displayedMonth.month,
    );
    _dayFocusNodes = List<FocusNode>.generate(
      daysInMonth,
      (int index) =>
          FocusNode(skipTraversal: true, debugLabel: 'Day ${index + 1}'),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check to see if the focused date is in this month, if so focus it.
    final DateTime? focusedDate = _FocusedDate.maybeOf(context)?.date;
    if (focusedDate != null &&
        widget.calendarDelegate.isSameMonth(
          widget.displayedMonth,
          focusedDate,
        )) {
      _dayFocusNodes[focusedDate.day - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (final FocusNode node in _dayFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _dayFocusChanged(bool focused) {
    if (focused) {
      final TraversalDirection? focusDirection = _FocusedDate.maybeOf(
        context,
      )?.scrollDirection;
      if (focusDirection != null) {
        ScrollPositionAlignmentPolicy policy =
            ScrollPositionAlignmentPolicy.explicit;
        switch (focusDirection) {
          case TraversalDirection.up:
          case TraversalDirection.left:
            policy = ScrollPositionAlignmentPolicy.keepVisibleAtStart;
          case TraversalDirection.right:
          case TraversalDirection.down:
            policy = ScrollPositionAlignmentPolicy.keepVisibleAtEnd;
        }
        Scrollable.ensureVisible(
          primaryFocus!.context!,
          duration: _monthScrollDuration,
          alignmentPolicy: policy,
        );
      }
    }
  }

  Widget _buildDayItem(
    BuildContext context,
    DateTime dayToBuild,
    int firstDayOffset,
    int daysInMonth,
  ) {
    final int day = dayToBuild.day;

    final bool isDisabled =
        dayToBuild.isAfter(widget.lastDate) ||
        dayToBuild.isBefore(widget.firstDate);
    final bool isToday = widget.calendarDelegate.isSameDay(
      widget.currentDate,
      dayToBuild,
    );
    final BookedDateRange? booking = _bookedRangeForDay(dayToBuild);
    final DateTime previousDay = widget.calendarDelegate.addDaysToDate(
      dayToBuild,
      -1,
    );
    final BookedDateRange? previousBooking = _bookedRangeForDay(previousDay);
    final BookedDateRange? nextBooking = _bookedRangeForDay(
      widget.calendarDelegate.addDaysToDate(dayToBuild, 1),
    );
    final bool bookedHasLeadingNeighbor =
        booking != null && _isSameBookedRange(booking, previousBooking);
    final bool bookedHasTrailingNeighbor =
        booking != null && _isSameBookedRange(booking, nextBooking);
    final bool showBookingLabel =
        booking != null &&
        (!_isInDisplayedMonth(previousDay) ||
            !_isSameBookedRange(booking, previousBooking));

    return _DayItem(
      calendarDelegate: widget.calendarDelegate,
      day: dayToBuild,
      focusNode: _dayFocusNodes[day - 1],
      onBookedDayTap: booking == null
          ? null
          : () => widget.onBookedDateTap(booking),
      bookingLabel: showBookingLabel ? booking.bookedBy : null,
      onFocusChange: _dayFocusChanged,
      bookedHighlightColor: booking == null
          ? Theme.of(context).colorScheme.errorContainer
          : _bookedRangeHighlightColor,
      isDisabled: isDisabled,
      isToday: isToday,
      isBooked: booking != null,
      bookedHasLeadingNeighbor: bookedHasLeadingNeighbor,
      bookedHasTrailingNeighbor: bookedHasTrailingNeighbor,
    );
  }

  bool _isSameBookedRange(BookedDateRange? a, BookedDateRange? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.range.start == b.range.start &&
        a.range.end == b.range.end &&
        a.bookedBy == b.bookedBy &&
        a.bookingId == b.bookingId;
  }

  bool _isInDisplayedMonth(DateTime day) {
    return day.year == widget.displayedMonth.year &&
        day.month == widget.displayedMonth.month;
  }

  BookedDateRange? _bookedRangeForDay(DateTime day) {
    for (final BookedDateRange booking in widget.bookedDateRanges) {
      if (booking.contains(day)) {
        return booking;
      }
    }
    return null;
  }

  Widget _buildEdgeBox(BuildContext context, bool isHighlighted, Color color) {
    const Widget empty = LimitedBox(
      maxWidth: 0.0,
      maxHeight: 0.0,
      child: SizedBox.expand(),
    );
    return isHighlighted ? ColoredBox(color: color, child: empty) : empty;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final int year = widget.displayedMonth.year;
    final int month = widget.displayedMonth.month;
    final int daysInMonth = widget.calendarDelegate.getDaysInMonth(year, month);
    final int dayOffset = widget.calendarDelegate.firstDayOffset(
      year,
      month,
      localizations,
    );
    final int weeks = ((daysInMonth + dayOffset) / DateTime.daysPerWeek).ceil();
    final double gridHeight =
        weeks * _monthItemRowHeight + (weeks - 1) * _monthItemSpaceBetweenRows;
    final dayItems = <Widget>[];

    // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
    // a leap year.
    for (int day = 0 - dayOffset + 1; day <= daysInMonth; day += 1) {
      if (day < 1) {
        dayItems.add(
          const LimitedBox(
            maxWidth: 0.0,
            maxHeight: 0.0,
            child: SizedBox.expand(),
          ),
        );
      } else {
        final DateTime dayToBuild = widget.calendarDelegate.getDay(
          year,
          month,
          day,
        );
        final Widget dayItem = _buildDayItem(
          context,
          dayToBuild,
          dayOffset,
          daysInMonth,
        );
        dayItems.add(dayItem);
      }
    }

    // Add the leading/trailing edge containers to each week in order to
    // correctly extend the range highlight.
    final paddedDayItems = <Widget>[];
    for (var i = 0; i < weeks; i++) {
      final int start = i * DateTime.daysPerWeek;
      final int end = math.min(start + DateTime.daysPerWeek, dayItems.length);
      final List<Widget> weekList = dayItems.sublist(start, end);

      final DateTime dateAfterLeadingPadding = widget.calendarDelegate.getDay(
        year,
        month,
        start - dayOffset + 1,
      );
      // Only color the edge container if it is after the start date and
      // on/before the end date.
      final DateTime previousDate = widget.calendarDelegate.addDaysToDate(
        dateAfterLeadingPadding,
        -1,
      );
      final BookedDateRange? leadingBooking = _bookedRangeForDay(
        dateAfterLeadingPadding,
      );
      final bool isLeadingBooked = _isSameBookedRange(
        leadingBooking,
        _bookedRangeForDay(previousDate),
      );
      weekList.insert(
        0,
        _buildEdgeBox(
          context,
          isLeadingBooked,
          leadingBooking == null
              ? Theme.of(context).colorScheme.errorContainer
              : _bookedRangeHighlightColor,
        ),
      );

      // Only add a trailing edge container if it is for a full week and not a
      // partial week.
      if (end < dayItems.length ||
          (end == dayItems.length &&
              dayItems.length % DateTime.daysPerWeek == 0)) {
        final DateTime dateBeforeTrailingPadding = widget.calendarDelegate
            .getDay(year, month, end - dayOffset);
        // Only color the edge container if it is on/after the start date and
        // before the end date.
        final DateTime nextDate = widget.calendarDelegate.addDaysToDate(
          dateBeforeTrailingPadding,
          1,
        );
        final BookedDateRange? trailingBooking = _bookedRangeForDay(
          dateBeforeTrailingPadding,
        );
        final bool isTrailingBooked = _isSameBookedRange(
          trailingBooking,
          _bookedRangeForDay(nextDate),
        );
        weekList.add(
          _buildEdgeBox(
            context,
            isTrailingBooked,
            trailingBooking == null
                ? Theme.of(context).colorScheme.errorContainer
                : _bookedRangeHighlightColor,
          ),
        );
      }

      paddedDayItems.addAll(weekList);
    }

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: _maxCalendarContentWidth,
              ).tighten(height: _monthItemHeaderHeight),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: ExcludeSemantics(
                      child: Text(
                        widget.calendarDelegate.formatMonthYear(
                          widget.displayedMonth,
                          localizations,
                        ),
                        style: textTheme.bodyMedium!.apply(
                          color: themeData.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: _maxCalendarContentWidth,
              ),
              child: SizedBox(
                width: double.infinity,
                height: gridHeight,
                child: GridView.custom(
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: _monthItemGridDelegate,
                  childrenDelegate: SliverChildListDelegate(
                    paddedDayItems,
                    addRepaintBoundaries: false,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: _monthItemFooterHeight),
        ],
      ),
    );
  }
}

class _DayItem extends StatefulWidget {
  const _DayItem({
    required this.day,
    required this.focusNode,
    required this.onBookedDayTap,
    required this.bookingLabel,
    required this.onFocusChange,
    required this.bookedHighlightColor,
    required this.isDisabled,
    required this.isToday,
    required this.isBooked,
    required this.bookedHasLeadingNeighbor,
    required this.bookedHasTrailingNeighbor,
    required this.calendarDelegate,
  });

  final DateTime day;

  final FocusNode focusNode;

  final VoidCallback? onBookedDayTap;

  final String? bookingLabel;

  final ValueChanged<bool> onFocusChange;

  final Color bookedHighlightColor;

  final bool isDisabled;

  final bool isToday;

  final bool isBooked;

  final bool bookedHasLeadingNeighbor;

  final bool bookedHasTrailingNeighbor;

  final CalendarDelegate<DateTime> calendarDelegate;

  @override
  State<_DayItem> createState() => _DayItemState();
}

class _DayItemState extends State<_DayItem> {
  final WidgetStatesController _statesController = WidgetStatesController();

  @override
  void dispose() {
    _statesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final DatePickerThemeData datePickerTheme = DatePickerTheme.of(context);
    final DatePickerThemeData defaults = DatePickerTheme.defaults(context);
    final TextDirection textDirection = Directionality.of(context);

    BoxDecoration? decoration;
    TextStyle? itemStyle = textTheme.bodyMedium;

    T? effectiveValue<T>(T? Function(DatePickerThemeData? theme) getProperty) {
      return getProperty(datePickerTheme) ?? getProperty(defaults);
    }

    final states = <WidgetState>{
      if (widget.isDisabled) WidgetState.disabled,
      if (widget.isBooked) WidgetState.selected,
    };

    _statesController.value = states;

    final WidgetStateProperty<Color?> dayOverlayColor =
        WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) => effectiveValue(
            (DatePickerThemeData? theme) =>
                theme?.dayOverlayColor?.resolve(states),
          ),
        );

    _HighlightPainter? highlightPainter;

    if (widget.isDisabled) {
      itemStyle = itemStyle?.apply(
        color: colorScheme.onSurface.withOpacity(0.38),
      );
    } else if (widget.isBooked) {
      if (widget.bookedHasLeadingNeighbor && widget.bookedHasTrailingNeighbor) {
        highlightPainter = _HighlightPainter(
          color: widget.bookedHighlightColor,
          style: _HighlightPainterStyle.highlightMiddle,
          textDirection: textDirection,
        );
      } else if (widget.bookedHasLeadingNeighbor) {
        highlightPainter = _HighlightPainter(
          color: widget.bookedHighlightColor,
          style: _HighlightPainterStyle.highlightLeading,
          textDirection: textDirection,
        );
      } else if (widget.bookedHasTrailingNeighbor) {
        highlightPainter = _HighlightPainter(
          color: widget.bookedHighlightColor,
          style: _HighlightPainterStyle.highlightTrailing,
          textDirection: textDirection,
        );
      } else {
        highlightPainter = _HighlightPainter(
          color: widget.bookedHighlightColor,
          style: _HighlightPainterStyle.highlightAll,
          textDirection: textDirection,
        );
      }
      itemStyle = textTheme.labelSmall?.copyWith(
        color: colorScheme.onErrorContainer,
        fontWeight: FontWeight.w600,
      );
    } else if (widget.isToday) {
      // The current day gets a different text color and a circle stroke
      // border.
      itemStyle = itemStyle?.apply(color: colorScheme.primary);
      decoration = BoxDecoration(
        border: Border.all(color: colorScheme.primary),
        shape: BoxShape.circle,
      );
    }

    final String dayText = localizations.formatDecimal(widget.day.day);
    final bool showBookingName =
        widget.bookingLabel != null && widget.bookingLabel!.isNotEmpty;
    final String cellText = showBookingName ? widget.bookingLabel! : dayText;

    // We want the day of month to be spoken first irrespective of the
    // locale-specific preferences or TextDirection. This is because
    // an accessibility user is more likely to be interested in the
    // day of month before the rest of the date, as they are looking
    // for the day of month. To do that we prepend day of month to the
    // formatted full date.
    final semanticLabelSuffix = widget.isToday
        ? ', ${localizations.currentDateLabel}'
        : '';
    var semanticLabel =
        '$dayText, ${widget.calendarDelegate.formatFullDate(widget.day, localizations)}$semanticLabelSuffix';
    if (widget.bookingLabel != null && widget.bookingLabel!.isNotEmpty) {
      semanticLabel = '$semanticLabel, booked by ${widget.bookingLabel}';
    }

    Widget dayWidget = Container(
      decoration: decoration,
      alignment: Alignment.center,
      child: Semantics(
        label: semanticLabel,
        selected: widget.isBooked,
        child: Padding(
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: ExcludeSemantics(
            child: Text(
              cellText,
              style: itemStyle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );

    if (highlightPainter != null) {
      dayWidget = CustomPaint(painter: highlightPainter, child: dayWidget);
    }

    if (widget.isBooked && widget.onBookedDayTap != null) {
      dayWidget = InkResponse(
        focusNode: widget.focusNode,
        onTap: () {
          widget.onBookedDayTap!();
        },
        radius: _monthItemRowHeight / 2 + 4,
        statesController: _statesController,
        overlayColor: dayOverlayColor,
        onFocusChange: widget.onFocusChange,
        child: dayWidget,
      );
    }

    return dayWidget;
  }
}

/// Determines which style to use to paint the highlight.
enum _HighlightPainterStyle {
  /// Paints nothing.
  none,

  /// Paints a full-width rectangle for middle segments in a range.
  highlightMiddle,

  /// Paints a rectangle that occupies the leading half of the space.
  highlightLeading,

  /// Paints a rectangle that occupies the trailing half of the space.
  highlightTrailing,

  /// Paints a rectangle that occupies all available space.
  highlightAll,
}

/// This custom painter will add a background highlight to its child.
///
/// This highlight will be drawn depending on the [style], [color], and
/// [textDirection] supplied. It will either paint a rectangle on the
/// left/right, a full rectangle, or nothing at all. This logic is determined by
/// a combination of the [style] and [textDirection].
class _HighlightPainter extends CustomPainter {
  _HighlightPainter({
    required this.color,
    this.style = _HighlightPainterStyle.none,
    this.textDirection,
  });

  final Color color;
  final _HighlightPainterStyle style;
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    if (style == _HighlightPainterStyle.none) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (style) {
      case _HighlightPainterStyle.highlightMiddle:
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      case _HighlightPainterStyle.highlightLeading:
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(0, 0, size.width, size.height),
          ),
          paint,
        );
      case _HighlightPainterStyle.highlightTrailing:
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(0, 0, size.width, size.height),
          ),
          paint,
        );
      case _HighlightPainterStyle.highlightAll:
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(0, 0, size.width, size.height),
          ),
          paint,
        );
      case _HighlightPainterStyle.none:
        break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
