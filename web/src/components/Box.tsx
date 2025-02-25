import { fetchNui, useNuiEvent } from "@utilities/utils";
import { useState } from "react";

export const Box: React.FC = () => {
  const [visible, setVisible] = useState<boolean>(true);

  useNuiEvent('openBox', (data: any) => {
    console.log(JSON.stringify(data))
    setVisible(true)
  })

  const CloseUI = () => {
    fetchNui('closeBox')
      .then(() => { console.log("box is now closed :)") })
      .catch((e) => { console.log('\'was unable to close the box :(') })
  }

  if (!visible) return
  return (
    <div className="fixed top-4 right-4 z-50">
      <div className="bg-white rounded-lg shadow-lg p-6 max-w-sm">
        <h1 className="text-xl font-bold mb-4">Edit src/components/box.tsx to change me!</h1>
        <button
          onClick={CloseUI}
          className="bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-md transition-colors"
        >
          Close
        </button>
      </div>
    </div>
  )
}
