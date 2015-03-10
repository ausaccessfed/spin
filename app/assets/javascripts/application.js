// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require semantic-ui
//= require aaf-layout
//= require filterrific/filterrific-jquery

jQuery(function($) {
    $('.popup').popup({ inline: true, position: 'right center' });

    $('.help.button').popup();

    $.fn.form.settings.rules['urlsafe_base64'] = function(value) {
        return value.match(/^[\w-]*$/);
    };

    $.fn.form.settings.rules['provider_arn'] = function(value) {
        trimmed_value = $.trim(value)
        return trimmed_value.match(/^arn:aws:iam::\d+:saml-provider\/[A-Za-z0-9\.\_\-]{1,128}$/);
    };

    $.fn.form.settings.rules['role_arn'] = function(value) {
        trimmed_value = $.trim(value)
        return trimmed_value.match(/^arn:aws:iam::\d+:role\/[A-Za-z0-9\+\=\,\.\@\-\_]{1,64}$/);
    };
});
