import 'dart:typed_data';
import 'package:camera/camera.dart';

class FormatConvert {
  static Uint8List convertUint8List(CameraImage image) {

    // 获取图像数据
    List<Plane> planes = image.planes;
    Uint8List yPlaneBytes = planes[0].bytes;
    Uint8List uPlaneBytes = planes[1].bytes;
    Uint8List vPlaneBytes = planes[2].bytes;

    int width = image.width;
    int height = image.height;

    // 根据不同的图像格式进行处理
    if (image.format.group == ImageFormatGroup.yuv420) {
      int ySize = width * height;
      int uvSize = ySize ~/ 4;
      int totalSize = ySize + uvSize * 2;

      Uint8List yuvBytes = Uint8List(totalSize + 4);
      ByteData byteData = yuvBytes.buffer.asByteData();
      byteData.setUint16(0, width, Endian.little);
      byteData.setUint16(2, height, Endian.little);
      yuvBytes.setAll(4, yPlaneBytes);
      yuvBytes.setAll(ySize + 4, uPlaneBytes);
      yuvBytes.setAll(ySize + uvSize + 4, vPlaneBytes);
      return yuvBytes;
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      // BGRA_8888 格式
      Uint8List yuvBytes =
          Uint8List.fromList(yPlaneBytes + uPlaneBytes + vPlaneBytes);
      int numPixels = yuvBytes.length ~/ 4; // 每个像素由四个字节组成

      // 创建单字节数组，每个像素用一个字节表示
      Uint8List byteArray = Uint8List(numPixels);

      int index = 0;
      for (int i = 0; i < numPixels; i++) {
        // 提取 B、G、R 通道值
        int b = yuvBytes[index++];
        int g = yuvBytes[index++];
        int r = yuvBytes[index++];
        index++; // 跳过 A 通道值

        // 合并 B、G、R 通道值为一个字节，并存入单字节数组
        byteArray[i] = ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF);
      }

      return byteArray;
    } else {
      throw Exception('Unsupported image format');
    }
  }
}
