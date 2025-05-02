import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trevor_app/theme.dart';



const List<Widget> feedbackTypes = <Widget>[
  Text('Communication', style: TextStyle(fontSize: 12)),
  Text('App', style: TextStyle(fontSize: 12))
];


class FeedbackApp extends StatefulWidget {
  const FeedbackApp({super.key});

  @override
  State<FeedbackApp> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<FeedbackApp> {

  final List<bool> _selectedFeedbackType = <bool>[true, false];
  final _communicationFormKey = GlobalKey<_CommunicationFeedbackFormState>();
  final _appFormKey = GlobalKey<_AppFeedbackFormState>();

  void _submit() async {
    if (_selectedFeedbackType[0]) {
      // Communication form is active
      final formState = _communicationFormKey.currentState;
      if (formState != null) {
        // Get all form data
        final Map<String, dynamic>  formData = {
          'communicationsFormQuestion1': formState.communicationsFormQuestion1.text,
          'communicationsFormQuestion2': formState.selectedCommAnswer ?? 0,
          'communicationsFormQuestion3': formState._selectedRating.where((isSelected) => isSelected).length,
        };

        await sendData(formData);
        // Reset form after submission
        formState.resetForm();
      }
    } else {
      // App form is active
      final formState = _appFormKey.currentState;
      // if appFormquestinon2 is not answered it will be 0 so invalidate
      if (formState != null) {
        var rating = formState._selectedRating.where((isSelected) => isSelected).length;
        if (rating == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please give us a rating'))
          );
          return;
        }

        final Map<String, dynamic>  formData = {
          'appFormQuestion1': formState.appFormQuestion1.text,
          'appFormQuestion2': formState._selectedRating.where((isSelected) => isSelected).length,
        };

        await sendData(formData);
        // Reset form after submission
        formState.resetForm();
      }
    }

  }

  Future<void> sendData(formData) async {
    try {
      await FirebaseFirestore.instance
        .collection('conversationFeedback')
        .add(formData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Feedback submitted. Thank you!'))
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting feedback: $error'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
          children: <Widget>[
            Text(localizations.feedback, style: theme.textTheme.displayLarge),
            SizedBox(height: 16),
            Text(
               _selectedFeedbackType[0]
              ? localizations.feedbackDescriptionCommunications
              : localizations.feedbackDescriptionApp,
              style: theme.textTheme.bodyLarge,
            ),
              const SizedBox(height: 25),
              ToggleButtons(
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedFeedbackType.length; i++) {
                      _selectedFeedbackType[i] = i == index;
                    }
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: AppTheme.getButtonColor(context, index: 2),
                selectedColor: Colors.white,
                fillColor: AppTheme.getButtonColor(context, index: 2),
                color: AppTheme.getButtonColor(context, index: 2),
                constraints: const BoxConstraints(
                  minHeight: 60.0,
                  minWidth: 100.0),
                isSelected: _selectedFeedbackType,
                children:
                 <Widget>[
                  Text(localizations.communication, style: TextStyle(fontSize: 12)),
                  Text(localizations.app, style: TextStyle(fontSize: 12))
                ],
              ),
                  SizedBox(
                      height: MediaQuery.of(context).size.width * 0.1,
                  ),
          // Show either Communication or App form based on selection
          _selectedFeedbackType[0]
              ? CommunicationFeedbackForm(key: _communicationFormKey)
              : AppFeedbackForm(key: _appFormKey),
            // submit button
             ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.green),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        localizations.submit,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                        ),
                    ),
                ),
                onPressed: () => _submit(),
            ),
          ]
        )
      ),
    );
  }
}


const List<Widget> ratingsCommunication = <Widget>[
  Text('1'),
  Text('2'),
  Text('3'),
  Text('4'),
  Text('5'),
  Text('6'),
  Text('7'),
  Text('8'),
  Text('9'),
  Text('10'),
];
class CommunicationFeedbackForm extends StatefulWidget {
  const CommunicationFeedbackForm({super.key});

  @override
  State<CommunicationFeedbackForm> createState() => _CommunicationFeedbackFormState();
}

/*
  This is the Communication Feedback Form
*/
class _CommunicationFeedbackFormState extends State<CommunicationFeedbackForm> {
  final List<bool> _selectedRating = List.generate(10, (_) => false);
  final communicationsFormQuestion1 = TextEditingController();

  List<bool> _selectedCommOption = [false, false, false];
  final List<String> _commOptions = ["Better", "Same", "Worse"];

  // Map it so that Better -> 1, Same -> 2, Worse -> 3
  int? get selectedCommAnswer {
    for (int i = 0; i < _selectedCommOption.length; i++) {
      if (_selectedCommOption[i]) {
        return i + 1;
      }
    }
    return null;
  }

  // Method to reset form fields
  void resetForm() {
    communicationsFormQuestion1.clear();

    setState(() {
      // Reset 0-10 scale to all false
      for (int i = 0; i < _selectedRating.length; i++) {
        _selectedRating[i] = false;
      }
      // Reset better/same/worse:
      _selectedCommOption = [false, false, false];
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    return Column(
      children: [
        TextFormField(
          controller: communicationsFormQuestion1,
          cursorColor: AppTheme.getButtonColor(context, index: 2),
          decoration: AppTheme.getFormInputDecoration(
            context,
            localizations.communicationsFormQuestion1
          ),
          keyboardType: TextInputType.text,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.width * 0.1,
        ),
        Text(
          localizations.communicationsFormQuestion2,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppTheme.getButtonColor(context, index: 2),
            ),
          ),
        const SizedBox(height: 10),
        // Togglebuttons for "Worse, Same, Better"
        ToggleButtons(
          onPressed: (int index) {
            setState(() {
              for (int i = 0; i < _selectedCommOption.length; i++) {
                _selectedCommOption[i] = i == index;
              }
            });
          },
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          selectedBorderColor: AppTheme.getButtonColor(context, index: 2).withAlpha(99),
          selectedColor: Colors.white,
          fillColor: AppTheme.getButtonColor(context, index: 2),
          color: AppTheme.getButtonColor(context, index: 2),
          constraints: const BoxConstraints(minHeight: 60.0, minWidth: 100.0),
          isSelected: _selectedCommOption,
          children: _commOptions
              .map((option) => Text(option, style: const TextStyle(fontSize: 16)))
              .toList(),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.width * 0.1,
        ),
        Text(localizations.communicationsFormQuestion3, style: theme.textTheme.titleMedium?.copyWith(
          color: AppTheme.getButtonColor(context, index: 2),
        )),
        const SizedBox(height: 5),
        ToggleButtons(
          onPressed: (int index) {
            setState(() {
              // The button that is tapped is set to true, and the others to false.
              for (int i = 0; i < _selectedRating.length; i++) {
                _selectedRating[i] = i <= index;
              }
            });
          },
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          selectedBorderColor: AppTheme.getButtonColor(context, index: 2).withAlpha(99),
          selectedColor: Colors.white,
          fillColor:AppTheme.getButtonColor(context, index: 2),
          color: AppTheme.getButtonColor(context, index: 2),
          constraints: const BoxConstraints(
            minHeight: 60.0,
            minWidth: 30.0),
          isSelected: _selectedRating,
          children: ratingsCommunication,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.width * 0.1,
        ),
      ],
    );
  }
}


/*

  This is the Application Feedback Form

*/

const List<Widget> ratingsApp = <Widget>[
  Text('1'),
  Text('2'),
  Text('3'),
  Text('4'),
  Text('5'),
];

class AppFeedbackForm extends StatefulWidget {
  const AppFeedbackForm({super.key});

  @override
  State<AppFeedbackForm> createState() => _AppFeedbackFormState();
}

class _AppFeedbackFormState extends State<AppFeedbackForm> {
  final List<bool> _selectedRating = List.generate(5, (_) => false);
  final appFormQuestion1 = TextEditingController();

  // Method to reset form fields
  void resetForm() {
    appFormQuestion1.clear();
    setState(() {
      // Reset 0-10 scale to all false
      for (int i = 0; i < _selectedRating.length; i++) {
        _selectedRating[i] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    return Column(
      children: [
        TextFormField(
          controller: appFormQuestion1,
          cursorColor: AppTheme.getButtonColor(context, index: 2),
          decoration: AppTheme.getFormInputDecoration(
            context,
            local.appFormQuestion1,
          ),
          keyboardType: TextInputType.text,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.width * 0.1,
        ),
        Text(local.appFormQuestion2, style: theme.textTheme.titleSmall?.copyWith(
          color : AppTheme.getButtonColor(context, index: 2)
        )),
        const SizedBox(height: 5),
        ToggleButtons(
          onPressed: (int index) {
            setState(() {
              // The buttons that are <= than the one that is tapped is set to true,
              for (int i = 0; i < _selectedRating.length; i++) {
                _selectedRating[i] = i <= index;
              }
            });
          },
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          selectedBorderColor: AppTheme.getButtonColor(context, index: 2).withAlpha(99),
          selectedColor: Colors.white,
          fillColor: AppTheme.getButtonColor(context, index: 2),
          color: AppTheme.getButtonColor(context, index: 2),
          constraints: const BoxConstraints(
            minHeight: 60.0,
            minWidth: 40.0),
          isSelected: _selectedRating,
          children: ratingsApp,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.width * 0.1,
        ),
      ],
    );
  }
}

