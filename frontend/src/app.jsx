import { useState } from "react";
import ElderHome from "./pages/ElderHome";
import "./App.css";

function App() {
  const [currentScreen, setCurrentScreen] = useState("home");

  return (
    <ElderHome
      currentScreen={currentScreen}
      setCurrentScreen={setCurrentScreen}
    />
  );
}

export default App;
