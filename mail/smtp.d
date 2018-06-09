/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.mail.smtp;

import diamond.core.apptype;

static if (isWeb)
{
  import vibe.d : SMTPClientSettings, SMTPAuthType, SMTPConnectionType,
                  TLSContext, TLSPeerValidationMode, TLSVersion,
                  Mail, sendMail;

  import diamond.errors.checks;
  import diamond.core.traits;
  import diamond.security.validation.sensitive;

  // Alias to SMTPAuthType.
  mixin(createEnumAlias!SMTPAuthType("SmtpAuthType"));

  // Alias to SMTPConnectionType.
  mixin(createEnumAlias!SMTPConnectionType("SmtpConnectionType"));

  /// Wrapper around smtp client settings.
  final class SmtpClientSettings
  {
    private:
    /// The raw vibe.d smtp settings.
    SMTPClientSettings _settings;

    /// Boolean determining whether the mail should allow sensitive data or not.
    bool _allowSensitiveData;

    public:
    final:
    /// Creates new smtp client settings.
    this()
    {
      _settings = new SMTPClientSettings;
    }

    /**
    * Creates new smtp client settings.
    * Params:
    *   host = The host of the smtp server.
    *   port = The port of the smtp server.
    */
    this(string host, ushort port)
    {
      _settings = new SMTPClientSettings(host, port);
    }

    /**
    * Creates new smtp client settings.
    * Params:
    *   host =     The host of the smtp server.
    *   port =     The port of the smtp server.
    *   username = The username to use for the authentication.
    *   password = The password to use for the authentication.
    */
    this(string host, ushort port, string username, string password)
    {
      this(host, port);

      this.username = username;
      this.password = password;
    }

    @property
    {
      /// Gets the authentication type.
      SmtpAuthType authType() { return cast(SmtpAuthType)_settings.authType; }

      /// Sets the authentication type.
      void authType(SmtpAuthType newAuthType)
      {
        _settings.authType = cast(SMTPAuthType)newAuthType;
      }

      /// Gets the connection type.
      SmtpConnectionType connectionType() { return cast(SmtpConnectionType)_settings.connectionType; }

      /// Sets the connection type.
      void connectionType(SmtpConnectionType newConnectionType)
      {
        _settings.connectionType = cast(SMTPConnectionType)newConnectionType;
      }

      /// Gets the host.
      string host() { return _settings.host; }

      /// Sets the host.
      void host(string newHost)
      {
        _settings.host = newHost;
      }

      /// Gets the local name.
      string localName() { return _settings.localname; }

      /// Sets the local name.
      void localName(string newLocalName)
      {
        _settings.localname = newLocalName;
      }

      /// Gets the username for the authentication.
      string username() { return _settings.username; }

      /// Sets the username for the authentication.
      void username(string newUsername)
      {
        _settings.username = newUsername;
      }

      /// Gets the password for the authentication.
      string password() { return _settings.password; }

      /// Sets the password for the authentication.
      void password(string newPassword)
      {
        _settings.password = newPassword;
      }

      /// Gets the port.
      ushort port() { return _settings.port; }

      /// Sets the port.
      void port(ushort newPort)
      {
        _settings.port = newPort;
      }

      /// Get the tls context setup.
      void delegate(scope TLSContext) @safe tlsContextSetup() { return _settings.tlsContextSetup; }

      /// Sets the tls context setup.
      void tlsContextSetup(void delegate(scope TLSContext) @safe newContextSetup)
      {
        _settings.tlsContextSetup = newContextSetup;
      }

      /// Gets the tls validation mode.
      TLSPeerValidationMode tlsValidationMode() { return _settings.tlsValidationMode; }

      /// Sets the tls validation mode.
      void tlsValidationMode(TLSPeerValidationMode newValidationMode)
      {
        _settings.tlsValidationMode = newValidationMode;
      }

      /// Gets the tls version.
      TLSVersion tlsVersion() { return _settings.tlsVersion; }

      /// Sets the tls version.
      void tlsVersion(TLSVersion newVersion)
      {
        _settings.tlsVersion = newVersion;
      }

      /// Gets a boolean determining whether the mail should allow sensitive data or not.
      bool allowSensitiveData() { return _allowSensitiveData; }

      /// Sets a boolean determining whether the mail should allow sensitive data or not.
      void allowSensitiveData(bool shouldAllowSensitiveData)
      {
        _allowSensitiveData = shouldAllowSensitiveData;
      }
    }
  }

  /// Wrapper around an smtp mail.
  final class SmtpMail
  {
    private:
    /// The raw vibe.d mail.
    Mail _mail;
    /// The smtp client settings.
    SmtpClientSettings _settings;
    /// The sender.
    string _sender;
    /// The from-mail.
    string _fromMail;
    /// The recipient;
    string _recipient;
    /// The subject.
    string _subject;
    /// The message.
    string _message;
    /// The content type.
    string _contentType;

    public:
    final:
    /// Creates a new mail.
    this()
    {
      _mail = new Mail;
    }

    /**
    * Creates a new mail.
    * Params:
    *   settings = The settings for the mail.
    */
    this(SmtpClientSettings settings)
    {
      _settings = settings;
    }

    @property
    {
      /// Gets the sender.
      string sender() { return _sender; }

      /// Sets the sender.
      void sender(string newSender)
      {
        _sender = newSender;
      }

      /// Gets the from-mail.
      string fromMail() { return _fromMail; }

      /// Sets the from-mail.
      void fromMail(string newFromMail)
      {
        _fromMail = newFromMail;
      }

      /// Gets the recipient.
      string recipient() { return _recipient; }

      /// Sets the recipient.
      void recipient(string newRecipient)
      {
        _recipient = newRecipient;
      }

      /// Gets the subject.
      string subject() { return _subject; }

      /// Sets the subject.
      void subject(string newSubject)
      {
        _subject = newSubject;
      }

      /// Gets the message.
      string message() { return _message; }

      /// Set the message.
      void message(string newMessage)
      {
        _message = newMessage;
      }

      /// Gets the content type.
      string contentType() { return _contentType; }

      /// Sets the content type.
      void contentType(string newContentType)
      {
        _contentType = newContentType;
      }
    }

    /**
    * Adds a header.
    * Params:
    *   name =  The name of the header.
    *   value = The value of the header.
    */
    void addHeader(string name, string value)
    {
      _mail.headers[name] = value;
    }

    /**
    * Sends a mail with the mails current settings.
    * Params:
    *   level =    The security level to use for sensitive data if validation is turned on.
    */
    void send(SecurityLevel level = SecurityLevel.maximum)
    {
      enforce(_settings !is null, "The mail has no settings configured.");

      send(_settings, level);
    }

    /**
    * Sends a mail using specific settings.
    * Params:
    *   settings = The settings to use.
    *   level =    The security level to use for sensitive data if validation is turned on.
    */
    void send(SmtpClientSettings settings, SecurityLevel level = SecurityLevel.maximum)
    {
      enforce(settings !is null, "Cannot send a mail without settings.");

      enforce(_fromMail && _fromMail.length, "From-mail is missing.");
      enforce(_recipient && _recipient.length, "Recipient is missing.");
      enforce(_subject && _subject.length, "Subject is missing.");
      enforce(_message && _message.length, "Message is missing.");

      if (!settings.allowSensitiveData)
      {
        validateSensitiveData(_message, level);
      }

      if (_sender && _sender.length)
      {
        addHeader("Sender", _sender);
      }

      addHeader("From", _fromMail);
      addHeader("To", _recipient);
      addHeader("Subject", _subject);

      _mail.bodyText = _message;

      addHeader(
        "Content-Type",
        _contentType && _contentType.length ?
        _contentType : "text/plain;charset=utf-8"
      );

      sendMail(settings._settings, _mail);
    }
  }
}
