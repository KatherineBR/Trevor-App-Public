import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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

  void _submit() async {
    final localizations = AppLocalizations.of(context)!;
    if (_selectedFeedbackType[0]) {
      // Communication form is active
      final formState = _communicationFormKey.currentState;
      if (formState != null) {
        // Get all form data
        final Map<String, dynamic> formData = {
          'question1_yesNo': formState.yesNoAnswer == true ? localizations.yes : localizations.no,
          'question2_comparison': formState.comparison,
          'question2_rating': formState.rating,
          // Could add timestamp
        };

        // print('Communication Form Data: $formData');
        // Attempt to store data in firestore
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
        // Send data to firestore
        try {
          await FirebaseFirestore.instance
            .collection('appFeedback')
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
    }
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
  bool? _answeredYes;
  String? _comparisonResponse;
  int? _ratingResponse;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final List<String> comparisonOptions = [localizations.better, localizations.same, localizations.worse];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(localizations.communicationsFormDescription, style: theme.textTheme.titleLarge),
        const SizedBox(height: 20),

        // --- Question 1: Yes / No ---
        Text(localizations.communicationsFormQuestion1, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _answeredYes == true ? Colors.green : null,
                ),
                onPressed: () {
                  setState(() {
                    _answeredYes = true;
                  });
                },
                child: const Text('Yes'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _answeredYes == false ? Colors.red : null,
                ),
                onPressed: () {
                  setState(() {
                    _answeredYes = false;
                  });
                },
                child: const Text('No'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // --- Question 2 Part 1: Better / Same / Worse ---
        Text(localizations.communicationsFormQuestion2, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: comparisonOptions.map((option) {
            final isSelected = _comparisonResponse == option;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.blueAccent : null,
                  ),
                  onPressed: () {
                    setState(() {
                      _comparisonResponse = option;
                    });
                  },
                  child: Text(option),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 30),

        // --- Question 2 Part 2: Rating 0 to 10 ---
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(11, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _ratingResponse = index;
                });
              },
              child: Container(
                width: 28,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _ratingResponse == index ? Colors.orange : Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(index.toString()),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(localizations.bad, style: TextStyle(fontSize: 12)),
            Text(localizations.good, style: TextStyle(fontSize: 12)),
          ],
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // Expose values for the parent widget
  bool? get yesNoAnswer => _answeredYes;
  String? get comparison => _comparisonResponse;
  int? get rating => _ratingResponse;
}


class AppFeedbackForm extends StatefulWidget {
  const AppFeedbackForm({super.key});

  @override
  State<AppFeedbackForm> createState() => _AppFeedbackFormState();
}

const List<Widget> ratingsApp = <Widget>[
  Text('1'),
  Text('2'),
  Text('3'),
  Text('4'),
  Text('5'),
];

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
