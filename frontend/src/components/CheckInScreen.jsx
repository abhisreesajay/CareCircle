import { useState } from "react";

function CheckInScreen({ onBack }) {
  const [status, setStatus] = useState(null);

  const handleCheckIn = (selectedStatus) => {
    setStatus(selectedStatus);
    console.log("Check-in status:", selectedStatus);
  };

  if (status === "OK") {
    return (
      <div className="screen">
        <button className="back-btn" onClick={onBack}>
          ← BACK
        </button>

        <div className="screen-content">
          <h2>Check-in Completed</h2>

          <p className="confirmation-text">
            Your daily check-in has been completed successfully.
          </p>

          <div className="status-summary">
            <strong>Status: I'M OK</strong>
            <p>caregiver knows that you are doing well.</p>
          </div>

          <button
            className="big-action-btn"
            onClick={onBack}
          >
            BACK TO HOME
          </button>
        </div>
      </div>
    );
  }

  if (status === "HELP") {
    return (
      <div className="screen">
        <button className="back-btn" onClick={onBack}>
          ← BACK
        </button>

        <div className="screen-content">
          <h2>Help Requested</h2>

          <p className="confirmation-text">
           caregiver has been notified that you need help.
          </p>

          <div className="status-summary">
            <strong>HELP REQUEST SENT</strong>
            <p>Please stay somewhere safe and wait for assistance.</p>
          </div>

          <button
            className="big-action-btn"
            onClick={onBack}
          >
            BACK TO HOME
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="screen">
      <button className="back-btn" onClick={onBack}>
        ← BACK
      </button>

      <div className="screen-content">
        <h2>Daily Check-in</h2>

        <p className="screen-question">
          How are you feeling today?
        </p>

        <p className="checkin-description">
         caregiver know that you are safe and well.
        </p>

        <button
          className="status-btn ok-btn"
          onClick={() => handleCheckIn("OK")}
        >
          <strong>I'M OK</strong>
          <span>I'm feeling good today</span>
        </button>

        <button
          className="status-btn need-help-btn"
          onClick={() => handleCheckIn("HELP")}
        >
          <strong>I NEED HELP</strong>
          <span>I don't feel well or need assistance</span>
        </button>
      </div>
    </div>
  );
}

export default CheckInScreen;
