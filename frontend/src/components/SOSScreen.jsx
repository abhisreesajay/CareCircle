function SOSScreen({ onBack }) {

  const handleSOS = () => {

    const confirmed = window.confirm(
      "Are you sure you need emergency help?"
    );

    if (confirmed) {
      alert(
        "Emergency alert sent. Caregiver has been notified."
      );
    }
  };

  return (
    <div className="screen">

      <button className="back-btn" onClick={onBack}>
        ← BACK
      </button>

      <div className="screen-content">

        <h2>Emergency SOS</h2>

        <p className="screen-question">
          Press the button below if you need immediate help.
        </p>

        <button
          className="large-sos-btn"
          onClick={handleSOS}
        >
          SOS
        </button>

        <p className="warning-text">
          Emergency assistance will be requested.
        </p>

      </div>

    </div>
  );
}

export default SOSScreen;
