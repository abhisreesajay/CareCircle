function NearbyServicesScreen({ onBack }) {

  const findServices = () => {

    if (!navigator.geolocation) {
      alert(
        "Location is not available on this device."
      );
      return;
    }

    navigator.geolocation.getCurrentPosition(

      (position) => {

        const { latitude, longitude } =
          position.coords;

        const url =
          `https://www.google.com/maps/search/shops+restaurants/@${latitude},${longitude},14z`;

        window.open(url, "_blank");
      },

      () => {

        alert(
          "Unable to access your location. Please allow location access."
        );
      }
    );
  };

  return (
    <div className="screen">

      <button className="back-btn" onClick={onBack}>
        ← BACK
      </button>

      <div className="screen-content">

        <h2>Nearby Services</h2>

        <p className="screen-question">
          Find nearby shops and restaurants.
        </p>

        <button
          className="big-action-btn"
          onClick={findServices}
        >
          FIND NEARBY SERVICES
        </button>

      </div>

    </div>
  );
}

export default NearbyServicesScreen;
