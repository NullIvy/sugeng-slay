ObjC.import('CoreImage'); ObjC.import('AppKit');
function run(argv) {
  const [src, dst, r, g, b] = argv;
  const ns = $.NSImage.alloc.initWithContentsOfFile(src);
  if (!ns || ns.isNil()) throw 'Gagal membaca ' + src;
  const img = $.CIImage.imageWithData(ns.TIFFRepresentation);
  const f = $.CIFilter.filterWithName('CIColorMonochrome');
  f.setValueForKey(img, 'inputImage');
  f.setValueForKey($.CIColor.colorWithRedGreenBlue(r/255, g/255, b/255), 'inputColor');
  f.setValueForKey($.NSNumber.numberWithDouble(1.0), 'inputIntensity');
  const rep = $.NSBitmapImageRep.alloc.initWithCIImage(f.outputImage);
  rep.representationUsingTypeProperties(4, $({})).writeToFileAtomically(dst, true);
  return 'OK';
}
