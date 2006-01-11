
import System.Environment (getArgs)

import Graphics.UI.Gtk
import Graphics.Rendering.Cairo
import Graphics.Rendering.Cairo.SVG

main :: IO ()
main = do

  (file:_) <- getArgs
  svg <- newSVGFromFile file
  let (width, height) = sizeSVG svg

  initGUI
  dia <- dialogNew
  dialogAddButton dia stockOk ResponseOk
  contain <- dialogGetUpper dia
  canvas <- drawingAreaNew
  onSizeRequest canvas $ return (Requisition width height)
  onExpose canvas $ updateCanvas canvas svg
  boxPackStartDefaults contain canvas
  widgetShow canvas
  dialogRun dia
  return ()

updateCanvas :: DrawingArea -> SVG -> Event -> IO Bool
updateCanvas canvas svg (Expose { eventArea=rect }) = do
  win <- drawingAreaGetDrawWindow canvas
  let (width, height) = sizeSVG svg
  (width', height') <- drawingAreaGetSize canvas
  renderWithDrawable win $ do
    scale (realToFrac width'  / realToFrac width)
          (realToFrac height' / realToFrac height)
    renderSVG svg
  return True