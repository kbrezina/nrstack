import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

public class Unzip {

	public static void main(String argv[]) {
		File targetDir = new File(argv.length > 0
				? argv[0]
				: ".");

		System.exit(unzip(targetDir, System.in));
	}

	public static int unzip(File targetDir, InputStream inputStream) {
		ZipInputStream zipStream = new ZipInputStream(inputStream);

		try {
			byte[] buffer = new byte[8192];

			for(ZipEntry zipEntry; (zipEntry = zipStream.getNextEntry()) != null;) {
				File fileEntry = new File(targetDir, zipEntry.getName());

				if(!zipEntry.isDirectory()) {
					fileEntry.getParentFile().mkdirs();

					FileOutputStream fileStream = new FileOutputStream(fileEntry);

					try {
						for(int len; (len = zipStream.read(buffer)) != -1;)
							fileStream.write(buffer, 0, len);
					}
					finally {
						fileStream.close();
					}
				}
				else
					fileEntry.mkdirs();
			}

			return 0;
		}
		catch(IOException e) {
			System.err.println(e.getMessage());
			return 1;
		}
		finally {
			try {
				zipStream.close();
			}
			catch(IOException e) {
				// ignore
			}
		}
	}

}
