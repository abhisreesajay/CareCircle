import CheckInScreen from "../components/CheckInScreen";
import VoiceCheckInScreen from "../components/VoiceCheckInScreen";
import SOSScreen from "../components/SOSScreen";
import NearbyHospitalsScreen from "../components/NearbyHospitalsScreen";
import NearbyServicesScreen from "../components/NearbyServicesScreen";
function ElderHome({ currentScreen, setCurrentScreen }) {
  if (currentScreen === "checkin") {
    return (
      <CheckInScreen
        onBack={() => setCurrentScreen("home")}
      />
    );
  }
  if (currentScreen === "voice") {
    return (
      <VoiceCheckInScreen
        onBack={() => setCurrentScreen("home")}
      />
    );
  }
  if (currentScreen === "sos") {
    return (
      <SOSScreen
        onBack={() => setCurrentScreen("home")}
      />
    );
  }

  if (currentScreen === "hospitals") {
    return (
      <NearbyHospitalsScreen
        onBack={() => setCurrentScreen("home")}
      />
    );
  }

  if (currentScreen === "services") {
    return (
      <NearbyServicesScreen
        onBack={() => setCurrentScreen("home")}
      />
    );
  }

  return (
    <div className="elder-home">

      <header className="elder-header">
        <h2>CARE CIRCLE</h2>

        <button
          className="logout-btn"
          onClick={() => alert("You have been logged out.")}
        >
          LOGOUT
        </button>
      </header>

      <main className="elder-main">

        <h1>Welcome</h1>

        <p className="welcome-text">
          How can we help you today?
        </p>

        <div className="elder-actions">

          <button
            className="elder-action checkin"
            onClick={() => setCurrentScreen("checkin")}
          >
            CHECK-IN
          </button>

          <button
            className="elder-action voice"
            onClick={() => setCurrentScreen("voice")}
          >
            VOICE CHECK-IN
          </button>

          <button
            className="elder-action sos"
            onClick={() => setCurrentScreen("sos")}
          >
            SOS
          </button>

          <button
            className="elder-action"
            onClick={() => setCurrentScreen("hospitals")}
          >
            NEARBY HOSPITALS
          </button>

          <button
            className="elder-action"
            onClick={() => setCurrentScreen("services")}
          >
            NEARBY SERVICES
          </button>

        </div>

      </main>

      <footer>
        CareCircle • Your family care companion
      </footer>

    </div>
  );
}

export default ElderHome;
