import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


const List<Widget> feedbackTypes = <Widget>[
  Text('Communication'),
  Text('App')
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

  void _submit() {
    if (_selectedFeedbackType[0]) {
      // Communication form is active
      final formState = _communicationFormKey.currentState;
      if (formState != null) {
        // Get all form data
        final Map<String, dynamic> formData = {
          'communicationsFormQuestion1': formState.communicationsFormQuestion1.text,
          'communicationsFormQuestion2': formState.communicationsFormQuestion2.text,
          'communicationsFormQuestion3': formState._selectedRating.where((isSelected) => isSelected).length,
        };

        // print('Communication Form Data: $formData');
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

        final Map<String, dynamic> formData = {
          'appFormQuestion1': formState.appFormQuestion1.text,
          'appFormQuestion2': formState._selectedRating.where((isSelected) => isSelected).length,
        };

        // print('App Form Data: $formData');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Feedback submitted. Thank you!'))
    );
  }

  @override
  Widget build(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.feedback),
      ),
      body: Center(
        child: Column(
        children: <Widget>[
            Text('Feedback type', style: theme.textTheme.titleSmall),
              const SizedBox(height: 5),
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
                selectedBorderColor: Colors.red[700],
                selectedColor: Colors.white,
                fillColor: Colors.red[200],
                color: Colors.red[400],
                constraints: const BoxConstraints(
                  minHeight: 60.0,
                  minWidth: 100.0),
                isSelected: _selectedFeedbackType,
                children: feedbackTypes,
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
                        "Submit",
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


class _CommunicationFeedbackFormState extends State<CommunicationFeedbackForm> {
  final List<bool> _selectedRating = List.generate(10, (_) => false);
  final communicationsFormQuestion1 = TextEditingController();
  final communicationsFormQuestion2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    return Column(
      children: [
        TextFormField(
          controller: communicationsFormQuestion1,
          decoration: InputDecoration(
            labelText: localizations.communicationsFormQuestion1,
          ),
          keyboardType: TextInputType.text,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.width * 0.1,
        ),
        TextFormField(
          controller: communicationsFormQuestion2,
          decoration: InputDecoration(
            labelText: localizations.communicationsFormQuestion2,
          ),
          validator: (value) {
            return null;
          },
        ),
        SizedBox(
          height: MediaQuery.of(context).size.width * 0.1,
        ),
        Text(localizations.communicationsFormQuestion3, style: theme.textTheme.titleSmall),
        // const SizedBox(height: 5)
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
          selectedBorderColor: Colors.red[700],
          selectedColor: Colors.white,
          fillColor: Colors.red[200],
          color: Colors.red[400],
          constraints: const BoxConstraints(
            minHeight: 60.0,
            minWidth: 40.0),
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

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    return Column(
      children: [
        TextFormField(
          controller: appFormQuestion1,
          decoration: InputDecoration(
            labelText: local.appFormQuestion1,
          ),
          keyboardType: TextInputType.text,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.width * 0.1,
        ),
        Text(local.appFormQuestion2, style: theme.textTheme.titleSmall),
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
          selectedBorderColor: Colors.red[700],
          selectedColor: Colors.white,
          fillColor: Colors.red[200],
          color: Colors.red[400],
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
