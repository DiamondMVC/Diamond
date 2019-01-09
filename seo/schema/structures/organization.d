/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organization;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.schemaobject;
  import diamond.seo.schema.structures.contactpoint;
  import diamond.seo.schema.structures.person;
  import diamond.seo.schema.structures.postaladdress;

  /// http://schema.org/Organization
  class Organization : SchemaObject
  {
    private:
    /// The name.
    string _name;
    /// The url.
    string _url;
    /// The contact point.
    ContactPoint[] _contactPoint;
    /// The email.
    string _email;
    /// The fax number.
    string _faxNumber;
    /// The member.
    Organization[] _member;
    /// The alumni.
    Person[] _alumni;
    /// The telephone.
    string _telephone;
    /// The sponsor.
    Organization _sponsor;
    /// The address.
    PostalAddress _address;
    /// The logo.
    string _logo;
    /// The description.
    string _description;

    public:
    /// Creates a new organization.
    this()
    {
      super("Organization");
    }

    /**
    * Creates a new organization.
    * Params:
    *   organizationType = The type of the organization.
    */
    protected this(string organizationType)
    {
      super(organizationType);
    }

    @property
    {
      final
      {
        /// Gets the name.
        string name() { return _name; }

        /// Sets the name.
        void name(string newName)
        {
          _name = newName;

          super.addField("name", _name);
        }

        /// Gets the url.
        string url() { return _url; }

        /// Sets the url.
        void url(string newUrl)
        {
          _url = newUrl;

          super.addField("url", _url);
        }

        /// Gets the contact point.
        ContactPoint[] contactPoint() { return _contactPoint; }

        /// Sets the contact point.
        void contactPoint(ContactPoint[] newContactPoint)
        {
          _contactPoint = newContactPoint;

          super.addField("contactPoint", _contactPoint);
        }

        /// Gets the email.
        string email() { return _email; }

        /// Sets the email.
        void email(string newEmail)
        {
          _email = newEmail;

          super.addField("email", _email);
        }

        /// Gets the fax number.
        string faxNumber() { return _faxNumber; }

        /// Sets the fax number.
        void faxNumber(string newFaxNumber)
        {
          _faxNumber = newFaxNumber;

          super.addField("faxNumber", _faxNumber);
        }

        /// Gets the member.
        Organization[] member() { return _member; }

        /// Sets the member.
        void member(Organization[] newMember)
        {
          _member = newMember;

          super.addField("member", _member);
        }

        /// Gets the alumni.
        Person[] alumni() { return _alumni; }

        /// Sets the alumni.
        void alumni(Person[] newAlumni)
        {
          _alumni = newAlumni;

          super.addField("alumni", _alumni);
        }

        /// Gets the telephone.
        string telephone() { return _telephone; }

        /// Sets the telephone.
        void telephone(string newTelephone)
        {
          _telephone = newTelephone;

          super.addField("telephone", _telephone);
        }

        /// Gets the sponsor.
        Organization sponsor() { return _sponsor; }

        /// Sets the sponsor.
        void sponsor(Organization newSponsor)
        {
          _sponsor = newSponsor;

          super.addField("sponsor", _sponsor);
        }

        /// Gets the address.
        PostalAddress address() { return _address; }

        /// Sets the address.
        void address(PostalAddress newAddress)
        {
          _address = newAddress;

          super.addField("address", _address);
        }

        /// Gets the logo.
        string logo() { return _logo; }

        /// Sets the logo.
        void logo(string newLogo)
        {
          _logo = newLogo;

          super.addField("logo", _logo);
        }

        /// Gets the description.
        string description() { return _description; }

        /// Sets the description.
        void description(string newDescription)
        {
          _description = newDescription;

          super.addField("description", _description);
        }
      }
    }
  }
}
