/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.person;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.schemaobject;
  import diamond.seo.schema.structures.postaladdress;

  /// http://schema.org/Person
  final class Person : SchemaObject
  {
    private:
    /// The name.
    string _name;
    /// The image.
    string _image;
    /// The same as.
    string _sameAs;
    /// The disambiguating description.
    string _disambiguatingDescription;
    /// The children.
    Person _children;
    /// The address.
    PostalAddress _address;
    /// The colleague.
    Person _colleague;
    /// The colleagues.
    Person[] _colleagues;
    /// The email.
    string _email;
    /// The job title.
    string _jobTitle;
    /// The url.
    string _url;
    /// The id.
    string _id;

    public:
    final:
    /// Creates a new person.
    this()
    {
      super("Person");
    }

    @property
    {
      /// Gets the name.
      string name() { return _name; }

      /// Sets the name.
      void name(string newName)
      {
        _name = newName;

        super.addField("name", _name);
      }

      /// Gets the image.
      string image() { return _image; }

      /// Sets the image.
      void image(string newImage)
      {
        _image = newImage;

        super.addField("image", _image);
      }

      /// Gets the same as.
      string sameAs() { return _sameAs; }

      /// Sets the same as.
      void sameAs(string newSameAs)
      {
        _sameAs = newSameAs;

        super.addField("sameAs", _sameAs);
      }

      /// Gets the disambiguating description.
      string disambiguatingDescription() { return _disambiguatingDescription; }

      /// Sets the disambiguating description.
      void disambiguatingDescription(string newDisambiguatingDescription)
      {
        _disambiguatingDescription = newDisambiguatingDescription;

        super.addField("disambiguatingDescription", _disambiguatingDescription);
      }

      /// Gets the children.
      Person children() { return _children; }

      /// Sets the children.
      void children(Person newChildren)
      {
        _children = newChildren;

        super.addField("children", _children);
      }

      /// Gets the address.
      PostalAddress address() { return _address; }

      /// Sets the address.
      void address(PostalAddress newPostalAddress)
      {
        _address = newPostalAddress;

        super.addField("address", _address);
      }

      /// Gets the colleague. Supersedes colleagues.
      Person colleague() { return _colleague; }

      /// Sets the colleague. Supersedes colleagues.
      void colleague(Person newColleague)
      {
        _colleague = newColleague;

        super.addField("colleague", _colleague);

        _colleagues = null;
        super.removeField("colleagues");
      }

      /// Get the colleagues. Superseded by colleague.
      Person[] colleagues() { return _colleagues; }

      /// Sets the colleagues. Superseded by colleague.
      void colleagues(Person[] newColleagues)
      {
        if (_colleague)
        {
          return;
        }

        _colleagues = newColleagues;

        super.addField("colleagues", _colleagues);
      }

      /// Gets the email.
      string email() { return _email; }

      /// Sets the email.
      void email(string newEmail)
      {
        _email = newEmail;

        super.addField("email", _email);
      }

      /// Gets the job title.
      string jobTitle() { return _jobTitle; }

      /// Sets the job title.
      void jobTitle(string newJobTitle)
      {
        _jobTitle = newJobTitle;
      }

      /// Gets the url.
      string url() { return _url; }

      /// Sets the url.
      void url(string newUrl)
      {
        _url = newUrl;
      }

      /// Gets the id. The field name is "@id"
      string id() { return _id; }

      /// Sets the id. The field name is "@id"
      void id(string newId)
      {
        _id = newId;

        super.addField("@id", _id);
      }
    }
  }
}
