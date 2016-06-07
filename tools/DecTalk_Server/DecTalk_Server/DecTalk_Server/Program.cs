using System;
using SharpTalk;
using System.Net;
using System.IO;
using System.Text;
using NAudio.Wave;
using NAudio.Lame;
using System.Configuration;
using System.Threading.Tasks;
using System.Linq;
using System.Collections.Generic;

namespace DecTalk
{
    class Program
    {
        static string entirePath = null;

        private static Dictionary<Guid, Stream> storedStreams = new Dictionary<Guid, Stream>();

        public static Stream GetStream(Guid guid)
        {
            lock (storedStreams)
            {
                return storedStreams[guid];
            }
        }

        public static void AddStream(Guid guid, Stream stream)
        {
            lock (storedStreams)
            {
                storedStreams.Add(guid, stream);
            }
        }

        public static void RemoveStream(Guid guid)
        {
            lock (storedStreams)
            {
                storedStreams.Remove(guid);
            }
        }

        static void Main(string[] args)
        {
            HttpListener listener = null;
            var server = ConfigurationManager.AppSettings["server"];
            var port = ConfigurationManager.AppSettings["port"];


            if (port == "0") entirePath = "http://" + server + "/";
            else entirePath = "http://" + server + ":" + port + "/";


            listener = new HttpListener();
            listener.Prefixes.Add(entirePath);
            listener.Start();
            Task.Run(async () =>
            {
                try
                {
                    while (true)
                    {
                        Console.WriteLine("Awaiting Connection...");
                        HttpListenerContext context = await listener.GetContextAsync();
                        Task.Run(async () => await ProcessRequest(context));
                    }
                }
                catch (HttpListenerException e)
                {
                    Console.WriteLine("Error Code: " + e.ErrorCode);
                    Console.WriteLine(e.Message);
                    Console.ReadLine();

                }
            });
        }

        public static async Task<Stream> WaveToMP3(Stream wavStream, int bitRate = 128)
        {
            Stream outStream = new MemoryStream();
            using (var reader = new RawSourceWaveStream(wavStream, new WaveFormat()))
            {
                using (var writer = new LameMP3FileWriter(outStream, new Mp3WaveFormat(11025, 1, 16, bitRate), bitRate))
                {
                    await reader.CopyToAsync(writer);
                    return outStream;
                }
            }
        }

        public static async Task ProcessRequest(HttpListenerContext context)
        {
            if (!String.IsNullOrEmpty(context.Request.QueryString["tts"]))
            {
                string msg = Convert.ToString(context.Request.QueryString["tts"]);
                Console.WriteLine(msg);

                Stream voiceStream = new MemoryStream();

                using (var tts = new FonixTalkEngine(LanguageCode.EnglishUS))
                {
                    tts.SpeakToStream(voiceStream, msg);
                }

                //We've written, so we have to go back to the top
                voiceStream.Seek(0, SeekOrigin.Begin);

                //Converts to MP3
                voiceStream = await WaveToMP3(voiceStream);

                //Resets to the top again
                voiceStream.Seek(0, SeekOrigin.Begin);

                //Generates a new file guid to keep the file in
                Guid fileGuid = Guid.NewGuid();

                AddStream(fileGuid, voiceStream);

                string streampath = entirePath + fileGuid.ToString();

                byte[] getBytes = Encoding.ASCII.GetBytes(streampath);
                System.IO.Stream output = context.Response.OutputStream;
                context.Response.ContentType = "text/plain";
                await output.WriteAsync(getBytes, 0, getBytes.Length);
                output.Close();
            }

            else
            {
                try
                {
                    //Gets the guid requested from the end of the url
                    Guid requested;
                    if (Guid.TryParse(context.Request.Url.Segments.Last(), out requested))
                    {
                        using (Stream stream = GetStream(requested))
                        {
                            Console.WriteLine("Sent file to client");
                            System.IO.Stream output = context.Response.OutputStream;
                            context.Response.ContentType = "audio/mpeg";
                            await stream.CopyToAsync(output);
                            output.Close();
                        }

                        RemoveStream(requested);
                    }
                }
                catch (FileNotFoundException e)
                {
                    Console.WriteLine("File was not found with: " + context.Request.Url.LocalPath);

                }
            }
        }
    }
}