// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function () {

    // Initialise checkbox
    $('.checkbox').checkbox();

    $('.ui.form')
        .form({
            terms: {
                identifier: 'agree_to_consent',
                rules: [
                    {
                        type: 'checked',
                        prompt: 'You must agree to the terms and conditions'
                    }
                ]
            }
        });
});

