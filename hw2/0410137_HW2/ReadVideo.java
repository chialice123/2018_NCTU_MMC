import java.io.*;

public class ReadVideo {
	FileInputStream video_in;
	int frame_num;
	
	public ReadVideo(String filename) throws Exception{
		video_in = new FileInputStream(filename);
		frame_num = 0;
	}
	
	public int nextframe(byte[] frame) throws Exception
    {
        int length = 0;
        String length_string;
        byte[] frame_length = new byte[5];

        //read current frame length
        video_in.read(frame_length,0,5);

        //transform frame_length to integer
        length_string = new String(frame_length);
        length = Integer.parseInt(length_string);

        return(video_in.read(frame,0,length));
    }
}