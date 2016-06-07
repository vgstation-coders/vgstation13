using System;
using SharpTalk;
using System.Net;
using System.IO;
using System.Text;
using NAudio.Wave;
using NAudio.Lame;
using System.Configuration;

namespace DecTalk
{
    class Program
    {
        static void Main(string[] args)
        {
            HttpListener listener = null;
            var path = "./temp.mp3";
            var server = ConfigurationManager.AppSettings["server"];
            var port = ConfigurationManager.AppSettings["port"];
            string entirePath = null;

            if (port == "0") entirePath = "http://" + server + "/";
            else entirePath = "http://" + server + ":" + port + "/";

            try {
                listener = new HttpListener();
                listener.Prefixes.Add(entirePath);
                listener.Start();
                while (true)
                {
                    Console.WriteLine("Awaiting Connection...");
                    HttpListenerContext context = listener.GetContext();
                    if(!String.IsNullOrEmpty(context.Request.QueryString["tts"]))
                    {
                       string msg = Convert.ToString(context.Request.QueryString["tts"]);
                        Console.WriteLine(msg);
                        using (var tts = new FonixTalkEngine(LanguageCode.EnglishUS))
                        {
                            tts.SpeakToWavFile("temp.wav", msg);
                        }

                        WaveToMP3("temp.wav", "temp.mp3");


                        string filePath = entirePath + "temp.mp3";
                        byte[] getBytes = Encoding.ASCII.GetBytes(filePath);
                        System.IO.Stream output = context.Response.OutputStream;
                        context.Response.ContentType = "text/plain";
                        output.Write(getBytes, 0, getBytes.Length);
                        output.Close();



                    }
                    if(context.Request.Url.AbsolutePath.EndsWith(".mp3"))
                    {
                        try
                        {
                            using (FileStream fs = File.Open(path, FileMode.Open, FileAccess.Read))
                            {
                                Console.WriteLine("Sent file to client");
                                System.IO.Stream output = context.Response.OutputStream;
                                context.Response.ContentType = "audio/mpeg";
                                fs.CopyTo(output);
                                output.Close();
                            }
                        } catch (FileNotFoundException e)
                        {
                            Console.WriteLine("File was not found with: " + context.Request.Url.LocalPath);

                        }
                    }
                }
            } catch (HttpListenerException e) {
                Console.WriteLine("Error Code: " + e.ErrorCode);
                Console.WriteLine(e.Message);
                Console.ReadLine();
                
            }
        }

        public static void WaveToMP3(string waveFileName, string mp3FileName, int bitRate = 128)
        {
            using (var reader = new WaveFileReader(waveFileName))
            using (var writer = new LameMP3FileWriter(mp3FileName, reader.WaveFormat, bitRate))
                reader.CopyTo(writer);
        }
    }
}