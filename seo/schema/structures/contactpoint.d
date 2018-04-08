/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.contactpoint;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.schemaobject;

  /// http://schema.org/ContactPoint
  final class ContactPoint : SchemaObject
  {
    private:
    /// The telephone.
    string _telephone;
    /// The contact type.
    string _contactType;
    /// The contact option.
    string[] _contactOption;
    /// The area served.
    string _areaServed;
    /// The available language.
    string _availableLanguage;

    public:
    final:
    /// Creates a new contact point.
    this()
    {
      super("ContactPoint");
    }

    @property
    {
      /// Gets the telephone.
      string telephone() { return _telephone; }

      /// Sets the telephone.
      void telephone(string newTelephone)
      {
        _telephone = newTelephone;

        super.addField("telephone", _telephone);
      }

      /// Gets the contact type.
      string contactType() { return _contactType; }

      /// Sets the contact type.
      void contactType(string newContactType)
      {
        _contactType = newContactType;

        super.addField("contactType", _contactType);
      }

      /// Gets the contact option.
      string[] contactOption() { return _contactOption; }

      /// Sets the contact option.
      void contactOption(string[] newContactOption)
      {
        _contactOption = newContactOption;

        super.addField("contactOption", _contactOption);
      }

      /// Gets the area served.
      string areaServed() { return _areaServed; }

      /// Sets the area served.
      void areaServed(string newAreaServed)
      {
        _areaServed = newAreaServed;

        super.addField("areaServed", _areaServed);
      }

      /// Gets the available langauge.
      string availableLanguage() { return _availableLanguage; }

      /// Sets the available language.
      void availableLanguage(string newAvailableLanguage)
      {
        _availableLanguage = newAvailableLanguage;

        super.addField("availableLanguage", _availableLanguage);
      }
    }
  }
}
