#!/usr/bin/env python3
"""
Main entry point for the Text-to-Speech Converter application.
"""

import argparse
import os
import sys
import json
from pathlib import Path

# Add the src directory to Python path for imports
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from tts_tool import TTSProcessor
from tts_tool import AdvancedTTSProcessor, BatchTTSProcessor
from tts_tool import DatasetLoader, DatasetAnalyzer
from tts_tool import create_interface


def main():
    """Main application entry point."""
    parser = argparse.ArgumentParser(
        description="Text-to-Speech Converter using Hugging Face models",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Launch web interface
  python main.py --web
  
  # Convert text to speech
  python main.py --text "Hello world" --output hello.wav
  
  # Batch conversion
  python main.py --batch texts.txt --output-dir batch_output
  
  # Analyze dataset
  python main.py --analyze-dataset lj_speech
  
  # Convert audio format
  python main.py --convert-audio input.wav --format mp3
        """
    )
    
    # General arguments
    parser.add_argument(
        "--model", 
        choices=["speecht5", "mms_tts", "bark"],
        default="speecht5",
        help="TTS model to use (default: speecht5)"
    )
    
    parser.add_argument(
        "--device",
        choices=["cpu", "cuda", "mps"],
        default="cpu",
        help="Device to run the model on (default: cpu)"
    )
    
    parser.add_argument(
        "--cache-dir",
        default="models_cache",
        help="Directory for caching downloaded models"
    )
    
    # Web interface arguments
    parser.add_argument(
        "--web",
        action="store_true",
        help="Launch web interface"
    )
    
    parser.add_argument(
        "--port",
        type=int,
        default=7860,
        help="Port for web interface (default: 7860)"
    )
    
    parser.add_argument(
        "--share",
        action="store_true",
        help="Create a shareable link for the web interface"
    )
    
    # Single conversion arguments
    parser.add_argument(
        "--text",
        help="Text to convert to speech"
    )
    
    parser.add_argument(
        "--output",
        help="Output audio file path"
    )
    
    parser.add_argument(
        "--emotion",
        choices=["neutral", "happy", "sad", "excited", "whisper"],
        default="neutral",
        help="Emotion for the voice"
    )
    
    parser.add_argument(
        "--language",
        default="en",
        help="Target language code"
    )
    
    parser.add_argument(
        "--normalize",
        action="store_true",
        default=True,
        help="Normalize audio levels"
    )
    
    # Batch conversion arguments
    parser.add_argument(
        "--batch",
        help="Input file with texts (one per line) or comma-separated list"
    )
    
    parser.add_argument(
        "--output-dir",
        default="batch_output",
        help="Output directory for batch processing"
    )
    
    parser.add_argument(
        "--workers",
        type=int,
        default=4,
        help="Number of parallel workers for batch processing"
    )
    
    # Audio conversion arguments
    parser.add_argument(
        "--convert-audio",
        help="Input audio file to convert"
    )
    
    parser.add_argument(
        "--format",
        choices=["mp3", "wav", "flac", "ogg"],
        default="mp3",
        help="Target format for audio conversion"
    )
    
    parser.add_argument(
        "--bitrate",
        choices=["128k", "192k", "256k", "320k"],
        default="192k",
        help="Bitrate for compressed audio formats"
    )
    
    # Dataset analysis arguments
    parser.add_argument(
        "--analyze-dataset",
        choices=["lj_speech", "common_voice", "vctk"],
        help="Dataset to analyze"
    )
    
    parser.add_argument(
        "--analysis-output",
        help="Output file for analysis results"
    )
    
    # Utility arguments
    parser.add_argument(
        "--list-models",
        action="store_true",
        help="List available TTS models"
    )
    
    parser.add_argument(
        "--model-info",
        choices=["speecht5", "mms_tts", "bark"],
        help="Get detailed information about a model"
    )
    
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Enable verbose output"
    )
    
    args = parser.parse_args()
    
    # Handle verbose output
    if args.verbose:
        print("🚀 Starting Text-to-Speech Converter...")
        print(f"📋 Configuration:")
        print(f"  Model: {args.model}")
        print(f"  Device: {args.device}")
        print(f"  Cache Directory: {args.cache_dir}")
    
    try:
        # List available models
        if args.list_models:
            list_available_models()
            return
        
        # Get model information
        if args.model_info:
            show_model_info(args.model_info)
            return
        
        # Launch web interface
        if args.web:
            launch_web_interface(args)
            return
        
        # Analyze dataset
        if args.analyze_dataset:
            analyze_dataset(args)
            return
        
        # Single text conversion
        if args.text:
            convert_single_text(args)
            return
        
        # Batch conversion
        if args.batch:
            batch_convert(args)
            return
        
        # Audio format conversion
        if args.convert_audio:
            convert_audio_format(args)
            return
        
        # If no specific action, launch interactive mode or web interface
        print("No specific action specified. Launching web interface...")
        args.web = True
        launch_web_interface(args)
        
    except KeyboardInterrupt:
        print("\n👋 Goodbye!")
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        if args.verbose:
            import traceback
            traceback.print_exc()
        sys.exit(1)


def list_available_models():
    """List all available TTS models."""
    print("\n🤖 Available TTS Models:")
    print("-" * 50)
    
    models = {
        "speecht5": "Microsoft SpeechT5 - High quality English TTS with speaker control",
        "mms_tts": "Facebook MMS-TTS - Multilingual support (1000+ languages), fast inference", 
        "bark": "Suno Bark - Creative multilingual TTS with sound effects and emotions"
    }
    
    for model_id, description in models.items():
        print(f"📌 {model_id:10} - {description}")
    
    print("\n💡 Choose a model using --model <model_name>")


def show_model_info(model_name: str):
    """Show detailed information about a specific model."""
    model_info = {
        "speecht5": {
            "description": "Microsoft SpeechT5 unified-modal TTS",
            "languages": ["English"],
            "quality": "High",
            "speed": "Medium",
            "memory_usage": "Medium",
            "special_features": ["Speaker embeddings", "Unified architecture"],
            "best_for": "Professional English TTS with voice control"
        },
        "mms_tts": {
            "description": "Facebook MMS-TTS VITS-based multilingual TTS", 
            "languages": ["20+ languages"],
            "quality": "Medium",
            "speed": "Fast",
            "memory_usage": "Low",
            "special_features": ["Multilingual", "Low resource usage", "Fast inference"],
            "best_for": "Multilingual applications and edge deployment"
        },
        "bark": {
            "description": "Suno Bark transformer-based creative TTS",
            "languages": ["13 languages"],
            "quality": "Very High",
            "speed": "Slow", 
            "memory_usage": "High",
            "special_features": ["Creative audio", "Emotion tags", "Sound effects", "Multilingual"],
            "best_for": "Creative content and highest quality audio"
        }
    }
    
    if model_name in model_info:
        info = model_info[model_name]
        print(f"\n📊 Model Information: {model_name}")
        print("-" * 40)
        print(f"Description: {info['description']}")
        print(f"Languages: {info['languages']}")
        print(f"Quality: {info['quality']}")
        print(f"Speed: {info['speed']}")
        print(f"Memory Usage: {info['memory_usage']}")
        print(f"Special Features: {', '.join(info['special_features'])}")
        print(f"Best For: {info['best_for']}")
    else:
        print(f"❌ Model '{model_name}' not found")


def launch_web_interface(args):
    """Launch the Gradio web interface."""
    print(f"\n🌐 Launching web interface on port {args.port}...")
    print(f"🔗 Access at: http://localhost:{args.port}")
    print("💡 Press Ctrl+C to stop the server")
    
    try:
        interface = create_interface(args.model)
        interface.launch(
            share=args.share,
            inbrowser=True,
            server_name="0.0.0.0",
            server_port=args.port,
            quiet=not args.verbose
        )
    except Exception as e:
        print(f"❌ Error launching web interface: {str(e)}")
        print("💡 Try running: pip install gradio transformers torch")
        raise


def convert_single_text(args):
    """Convert a single text to speech."""
    print(f"\n🎤 Converting text to speech...")
    print(f"📝 Text: {args.text[:100]}{'...' if len(args.text) > 100 else ''}")
    print(f"🤖 Model: {args.model}")
    print(f"😊 Emotion: {args.emotion}")
    print(f"🌍 Language: {args.language}")
    
    try:
        processor = AdvancedTTSProcessor(args.model)
        
        # Generate output filename if not provided
        if not args.output:
            text_preview = args.text[:20].replace(" ", "_").replace("/", "_")
            args.output = f"output_{text_preview}.wav"
        
        # Generate speech
        if args.emotion != "neutral":
            output_file = processor.generate_with_emotion(args.text, args.emotion, args.output)
        else:
            output_file = processor.generate_speech(args.text, args.output, normalize=args.normalize)
        
        print(f"✅ Speech generated successfully!")
        print(f"📁 Output file: {output_file}")
        
    except Exception as e:
        print(f"❌ Error generating speech: {str(e)}")
        raise


def batch_convert(args):
    """Convert multiple texts to speech."""
    print(f"\n📦 Starting batch conversion...")
    
    # Load texts
    if os.path.exists(args.batch):
        with open(args.batch, 'r', encoding='utf-8') as f:
            texts = [line.strip() for line in f.readlines() if line.strip()]
    else:
        # Assume comma-separated list
        texts = [text.strip() for text in args.batch.split(',') if text.strip()]
    
    if not texts:
        print("❌ No texts found in input")
        return
    
    print(f"📝 Found {len(texts)} texts to convert")
    print(f"📁 Output directory: {args.output_dir}")
    print(f"🔧 Workers: {args.workers}")
    
    try:
        processor = BatchTTSProcessor(args.model, args.workers)
        results = processor.process_batch(texts, args.output_dir)
        
        # Print summary
        successful = sum(1 for r in results if r['success'])
        failed = len(results) - successful
        
        print(f"\n📊 Batch Processing Complete!")
        print(f"✅ Successful: {successful}")
        print(f"❌ Failed: {failed}")
        print(f"📁 Results saved to: {args.output_dir}")
        
        if failed > 0:
            print("\n❌ Failed conversions:")
            for result in results:
                if not result['success']:
                    print(f"  - {result['text'][:50]}... Error: {result['error']}")
        
        # Save summary
        summary_file = os.path.join(args.output_dir, "batch_summary.json")
        processor.export_batch_summary(results, summary_file)
        print(f"📄 Summary saved to: {summary_file}")
        
    except Exception as e:
        print(f"❌ Error in batch conversion: {str(e)}")
        raise


def convert_audio_format(args):
    """Convert audio file to different format."""
    print(f"\n🔄 Converting audio format...")
    print(f"📁 Input: {args.convert_audio}")
    print(f"🎯 Target format: {args.format}")
    print(f"🎛️ Bitrate: {args.bitrate}")
    
    if not os.path.exists(args.convert_audio):
        print(f"❌ Input file not found: {args.convert_audio}")
        return
    
    try:
        from tts_tool import AudioFormatConverter
        
        converter = AudioFormatConverter()
        
        # Generate output filename
        base_name = os.path.splitext(args.convert_audio)[0]
        output_file = f"{base_name}_converted.{args.format}"
        
        # Convert format
        success = converter.convert_format(args.convert_audio, output_file, args.format, args.bitrate)
        
        if success:
            print(f"✅ Audio converted successfully!")
            print(f"📁 Output file: {output_file}")
        else:
            print("❌ Format conversion failed")
            
    except Exception as e:
        print(f"❌ Error converting audio format: {str(e)}")
        raise


def analyze_dataset(args):
    """Analyze a Hugging Face dataset."""
    print(f"\n📊 Analyzing dataset: {args.analyze_dataset}")
    
    try:
        loader = DatasetLoader()
        
        if args.analyze_dataset == "lj_speech":
            dataset = loader.get_lj_speech_dataset("train")
        elif args.analyze_dataset == "common_voice":
            dataset = loader.get_common_voice_dataset("en", "train")
        elif args.analyze_dataset == "vctk":
            dataset = loader.get_vctk_dataset("train")
        else:
            print(f"❌ Dataset '{args.analyze_dataset}' not supported")
            return
        
        print(f"📥 Dataset loaded: {len(dataset)} samples")
        
        # Analyze dataset
        stats = DatasetAnalyzer.analyze_dataset_statistics(dataset)
        
        # Print results
        print(f"\n📈 Dataset Analysis Results:")
        print(f"🗂️ Total samples: {stats.get('total_samples', 'N/A')}")
        
        if 'audio_analysis' in stats:
            audio_stats = stats['audio_analysis']
            print(f"🎵 Audio analysis:")
            print(f"  - Sample count: {audio_stats.get('sample_count', 'N/A')}")
            if 'duration_stats' in audio_stats:
                dur_stats = audio_stats['duration_stats']
                print(f"  - Avg duration: {dur_stats.get('mean', 0):.2f}s")
                print(f"  - Duration range: {dur_stats.get('min', 0):.2f}s - {dur_stats.get('max', 0):.2f}s")
        
        if 'text_analysis' in stats:
            text_stats = stats['text_analysis']
            print(f"📝 Text analysis:")
            print(f"  - Sample count: {text_stats.get('sample_count', 'N/A')}")
            if 'character_stats' in text_stats:
                char_stats = text_stats['character_stats']
                print(f"  - Avg length: {char_stats.get('mean', 0):.1f} chars")
                print(f"  - Length range: {char_stats.get('min', 0)} - {char_stats.get('max', 0)} chars")
        
        # Save analysis if requested
        if args.analysis_output:
            DatasetAnalyzer.create_dataset_report(dataset, args.analysis_output)
            print(f"📄 Detailed report saved to: {args.analysis_output}")
        
    except Exception as e:
        print(f"❌ Error analyzing dataset: {str(e)}")
        raise


if __name__ == "__main__":
    main()