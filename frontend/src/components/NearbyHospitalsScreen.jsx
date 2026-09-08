function NearbyHospitalsScreen({ onBack }) {
  const findHospitals = () => {
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
          `https://www.google.com/maps/search/hospitals/@${latitude},${longitude},14z`;
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

        <h2>Nearby Hospitals</h2>

        <p className="screen-question">
          Find hospitals near your current location.
        </p>

        <button
          className="big-action-btn"
          onClick={findHospitals}
        >
          FIND NEARBY HOSPITALS
        </button>

      </div>

    </div>
  );
}

export default NearbyHospitalsScreen;
