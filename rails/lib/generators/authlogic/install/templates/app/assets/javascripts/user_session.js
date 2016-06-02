$(function() {
  // Timeline:
  //  - 60 minutes:
  //    * session timeout refreshed from the server
  //    * session expires and user re-directed to login
  //  - 40 minutes:
  //    * session timeout refreshed from the server
  //    * user warned, and able to get another hour
  //  - 0 minutes:
  //    * session timeout read from page data. Timer started for 20 minutes before expiration.
  $('#session-timeout-modal').each( function() {

    var config = {
      minutes_of_warning: 20
    };

    var $modal = $( this );

    var expires_at = new Date();
    expires_at.setSeconds( expires_at.getSeconds() + $modal.data('seconds-remaining') );

    var warns_at = new Date(expires_at.valueOf());
    warns_at.setMilliseconds(warns_at.getMilliseconds() - config.minutes_of_warning * 60000);

    var warningTimer, countdownTimer, refreshTimeoutTimer;

    // Update timeout and show modal
    function sessionWarning() {
      refreshSessionExpiration().done( function() {
        if( msec_until_warning() > 0 ) {
          $modal.modal('hide');
          warningTimer = setTimeout(sessionWarning, msec_until_warning());
        }
        else {
          updateCountdown();
          $modal.modal({backdrop: 'static'});
          countdownTimer = setInterval(updateCountdown, 1000);
        }
      });
    }

    function sessionExpiration() {
      refreshSessionExpiration().done( function() {
        if( msec_until_expiration() > 0 ) {
          sessionWarning();
        }
        else {
          // login via /logout to avoid timing issues and ensure session is really dead
          window.location = '/logout?redirect_uri=' +
                            window.location.pathname +
                            window.location.search +
                            window.location.hash;
        }
      });
    }

    function updateCountdown() {
      var seconds_remaining = msec_until_expiration() / 1000;
      var seconds = Math.abs(seconds_remaining % 60);
      var minutes = Math.floor(seconds_remaining / 60);
      var message;

      if( minutes > 1 ) {
        message = sprintf('%2d minutes', minutes);
      }
      else if( minutes == 1 ) {
        message = sprintf('%2d minute', minutes);
      }
      else {
        message = sprintf('%02d seconds', seconds);
      }

      if( seconds_remaining <= 0 ) {
        sessionExpiration();
      }

      $('#session_timeout_countdown').text(message);
    }

    function msec_until_warning() {
      return Math.max(warns_at - new Date(), 0); // setTimeout may not like negative numbers
    }

    function msec_until_expiration() {
      return Math.max(expires_at - new Date(), 0); // setTimeout may not like negative numbers
    }

    function continueSession() {
      $.get('/user_session/continue', setSessionExpiration).done(function() {
        sessionWarning();
      });
    }

    // Request latest session timeout. Another active tab/window may have extended the session already.
    // TODO: consider keeping server requests down with _.throttle(function() {}, 10000);
    function refreshSessionExpiration() {
      return $.get('/user_session/timeout', setSessionExpiration);
    }

    // Update expires_at with given dateString. Accepts ISO 8601 strings.
    function setSessionExpiration(dateString) {
      expires_at = new Date(dateString) || new Date();

      warns_at = new Date(expires_at.valueOf());
      warns_at.setMilliseconds(warns_at.getMilliseconds() - config.minutes_of_warning * 60000);
    }

    $modal.find('.modal-footer .btn-primary').click(continueSession);

    // Kick things off...
    warningTimer = setTimeout(sessionWarning, msec_until_warning());
  });
});
