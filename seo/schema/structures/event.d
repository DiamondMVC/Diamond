/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.event;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.schemaobject;
  import diamond.seo.schema.structures.place;
  import diamond.seo.schema.structures.offer;
  import diamond.seo.schema.structures.organizations.performinggroup;

  /// http://schema.org/EventStatus
  enum EventStatus : string
  {
    /// Event cancelled.
    eventCancelled = "http://schema.org/EventCancelled",

    /// Event postponed.
    eventPostponed = "http://schema.org/EventPostponed",

    /// Event rescheduled.
    eventRescheduled = "http://schema.org/EventRescheduled",

    /// Event scheduled.
    eventScheduled = "http://schema.org/EventScheduled"
  }

  /// http://schema.org/Event
  class Event : SchemaObject
  {
    private:
    /// The location.
    Place _location;
    /// The name.
    string _name;
    /// The start date.
    string _startDate;
    /// The event status.
    EventStatus _eventStatus;
    /// The offers.
    Offer _offers;
    /// The performer.
    PerformingGroup[] _performer;
    /// The typical age range.
    string _typicalAgeRange;

    public:
    /// Creates a new event.
    this()
    {
      super("Event");
    }

    /**
    * Creates a new event.
    * Params:
    *   eventType = The type of the event.
    */
    protected this(string eventType)
    {
      super(eventType);
    }

    @property
    {
      final
      {
        /// Gets the location.
        Place location() { return _location; }

        /// Sets the location.
        void location(Place newLocation)
        {
          _location = newLocation;

          super.addField("location", _location);
        }

        /// Gets the name.
        string name() { return _name; }

        /// Sets the name.
        void name(string newName)
        {
          _name = newName;

          super.addField("name", _name);
        }

        /// Gets the start date.
        string startDate() { return _startDate; }

        /// Sets the start date.
        void startDate(string newStartDate)
        {
          _startDate = newStartDate;

          super.addField("startDate", _startDate);
        }

        /// Gets the event status.
        EventStatus eventStatus() { return _eventStatus; }

        /// Sets the event status.
        void eventStatus(EventStatus newEventStatus)
        {
          _eventStatus = newEventStatus;

          super.addField("eventStatus", cast(string)_eventStatus);
        }

        /// Gets the offers.
        Offer offers() { return _offers; }

        /// Sets the offers.
        void offers(Offer newOffers)
        {
          _offers = newOffers;

          super.addField("offers", _offers);
        }

        /// Gets the performer.
        PerformingGroup[] performer() { return _performer; }

        /// Sets the performer.
        void performer(PerformingGroup[] newPerformer)
        {
          _performer = newPerformer;

          super.addField("performer", _performer);
        }

        /// Gets the typical age range.
        string typicalAgeRange() { return _typicalAgeRange; }

        /// Sets the typical age range.
        void typicalAgeRange(string newTypicalAgeRange)
        {
          _typicalAgeRange = newTypicalAgeRange;

          super.addField("typicalAgeRange", _typicalAgeRange);
        }
      }
    }
  }
}
