import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:external_path/external_path.dart';
import 'permission_handler.dart';
import '../../features/home/model/lesson_response.dart';
import '../enums/custom_enums.dart';
import 'context_extension.dart';

class DownloadUtils {
  static Future<String?> generateAndSavePDF(
    dynamic lessonData, {
    required String fileName,
    required BuildContext context,
    String? subjectName,
  }) async {
    try {
      // Check and request storage permission
      final hasPermission = await StoragePermissionHandler.hasStoragePermission();
      if (!hasPermission) {
        final permissionGranted = await StoragePermissionHandler.requestStoragePermission();
        if (!permissionGranted) {
          // Show more helpful error message
          context.showToast(
            message: 'Storage permission denied. Please enable in Settings > Apps > Your App > Permissions',
            toastType: ToastType.error,
          );
          
          // Check if external storage is available
          final hasExternal = await StoragePermissionHandler.hasExternalStorage();
          if (!hasExternal) {
            context.showToast(
              message: 'Device may not have external storage. Will try internal storage.',
              toastType: ToastType.error,
            );
          }
          
          return null;
        }
      }

            // Generate PDF
      final pdf = pw.Document();
      
      print('Starting PDF generation...');
      
      // Add content to PDF based on lesson data structure
      if (lessonData is LessonResponse) {
        final daysCount = lessonData.days?.length ?? 0;
        final totalSessions = lessonData.days?.fold(0, (sum, day) => sum + (day.sessions?.length ?? 0)) ?? 0;
        
        print('Lesson data: $daysCount days, $totalSessions total sessions');
        print('Overview: ${lessonData.overview?.length ?? 0} characters');
        
        // Validate lesson data
        if (daysCount == 0) {
          print('Warning: No days found in lesson data');
        }
        
        if (totalSessions == 0) {
          print('Warning: No sessions found in lesson data');
        }
        
        _addLessonContentToPDF(pdf, lessonData, subjectName: subjectName);
      } else {
        // Handle other data types if needed
        _addGenericContentToPDF(pdf, lessonData.toString());
      }
      
      print('PDF content added, saving...');

      // Get the appropriate directory for saving with multiple fallbacks
      String? directoryPath;
      
      try {
        if (Platform.isAndroid) {
          // First try: External Downloads directory
          try {
            directoryPath = await ExternalPath.getExternalStoragePublicDirectory(
              ExternalPath.DIRECTORY_DOWNLOADS,
            );
            print('External Downloads path: $directoryPath');
          } catch (e) {
            print('External Downloads failed: $e');
          }
          
          // Second try: App's external directory
          if (directoryPath == null || directoryPath.isEmpty) {
            try {
              final appDocDir = await getApplicationDocumentsDirectory();
              directoryPath = '${appDocDir.path}/Downloads';
              print('App Downloads path: $directoryPath');
            } catch (e) {
              print('App Downloads failed: $e');
            }
          }
          
          // Third try: App's documents directory
          if (directoryPath == null || directoryPath.isEmpty) {
            try {
              final appDocDir = await getApplicationDocumentsDirectory();
              directoryPath = appDocDir.path;
              print('App Documents path: $directoryPath');
            } catch (e) {
              print('App Documents failed: $e');
            }
          }
          
          // Fourth try: Temporary directory
          if (directoryPath == null || directoryPath.isEmpty) {
            try {
              final tempDir = await getTemporaryDirectory();
              directoryPath = tempDir.path;
              print('Temp path: $directoryPath');
            } catch (e) {
              print('Temp directory failed: $e');
            }
          }
        } else {
          // For iOS, use app documents directory
          final appDocDir = await getApplicationDocumentsDirectory();
          directoryPath = appDocDir.path;
        }
      } catch (e) {
        print('All directory attempts failed: $e');
        // Final fallback: Use current directory
        directoryPath = Directory.current.path;
      }
      
      // Ensure directory exists and is writable
      if (directoryPath != null && directoryPath.isNotEmpty) {
        try {
          final dir = Directory(directoryPath);
          if (!await dir.exists()) {
            await dir.create(recursive: true);
            print('Created directory: $directoryPath');
          }
          
          // Test if directory is writable
          final testFile = File('$directoryPath/test_write.tmp');
          await testFile.writeAsString('test');
          await testFile.delete();
          print('Directory is writable: $directoryPath');
        } catch (e) {
          print('Directory creation/write test failed: $e');
          // Try to use a simpler path
          directoryPath = Directory.current.path;
        }
      }

      if (directoryPath == null || directoryPath.isEmpty) {
        context.showToast(
          message: 'Could not access any storage directory. Please check permissions.',
          toastType: ToastType.error,
        );
        return null;
      }
      
      print('Final directory path: $directoryPath');

      // Create file path
      final file = File('$directoryPath/$fileName.pdf');
      
      // Save PDF with validation
      final pdfBytes = await pdf.save();
      print('PDF generated: ${pdfBytes.length} bytes');
      
      if (pdfBytes.isEmpty) {
        context.showToast(
          message: 'PDF generation failed: No content generated',
          toastType: ToastType.error,
        );
        return null;
      }
      
      await file.writeAsBytes(pdfBytes);
      
      final fileNameWithPath = '$directoryPath/$fileName.pdf';
      final fileSize = file.lengthSync();
      
      // Validate file size is reasonable
      if (fileSize < 1000) { // Less than 1KB is suspicious
        print('Warning: Generated PDF is very small ($fileSize bytes). Content may be truncated.');
      }
      
      context.showToast(
        message: 'PDF saved successfully!\nLocation: ${fileNameWithPath.split('/').last}',
        toastType: ToastType.success,
      );
      
      print('PDF saved to: $fileNameWithPath');
      print('File size: $fileSize bytes');
      
      return file.path;
    } catch (e) {
      print('Error generating PDF: $e');
      context.showToast(
        message: 'Failed to generate PDF: $e',
        toastType: ToastType.error,
      );
      return null;
    }
  }

  static void _addLessonContentToPDF(pw.Document pdf, LessonResponse lesson, {String? subjectName}) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        maxPages: 100, // Allow up to 100 pages for very long lesson plans
        header: (pw.Context context) {
          // Add header to each page for better navigation
          return pw.Container(
            padding: pw.EdgeInsets.only(bottom: 10),
            child: pw.Text(
              'Lesson Plan - Page ${context.pageNumber}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
              textAlign: pw.TextAlign.center,
            ),
          );
        },
        footer: (pw.Context context) {
          // Add footer with page info
          return pw.Container(
            padding: pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
              textAlign: pw.TextAlign.center,
            ),
          );
        },
        build: (pw.Context context) {
          final List<pw.Widget> widgets = [];

          // Title - Use consistent format
          final title = subjectName != null && subjectName.isNotEmpty 
              ? 'Lesson Plan for $subjectName'
              : (lesson.theme ?? 'Lesson Plan');
              
          widgets.add(
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                border: pw.Border.all(color: PdfColors.blue200, width: 2),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          );
          widgets.add(pw.SizedBox(height: 24));

          // Overview
          if (lesson.overview != null) {
            widgets.add(
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  lesson.overview!,
                  style: pw.TextStyle(fontSize: 14),
                  softWrap: true, // Enable text wrapping for long overviews
                ),
              ),
            );
            widgets.add(pw.SizedBox(height: 20));
          }

          // Day-to-Day Plan
          widgets.add(
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                border: pw.Border.all(color: PdfColors.grey400, width: 1),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'DAY-TO-DAY PLAN',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          );
          widgets.add(pw.SizedBox(height: 20));

          // Add each day with optimized spacing for better page distribution
          if (lesson.days != null) {
            print('Processing ${lesson.days!.length} days for PDF...');
            
            for (int i = 0; i < lesson.days!.length; i++) {
              final day = lesson.days![i];
              print('Processing Day ${day.dayNumber} (${i + 1}/${lesson.days!.length})');
              
              // Add minimal spacing between days for better content density
              if (i > 0) {
                widgets.add(pw.SizedBox(height: 12));
              }
              
              widgets.add(_buildDaySection(day));
              
                        // Add minimal spacing between days
          if (i < lesson.days!.length - 1) {
            widgets.add(pw.SizedBox(height: 12));
          }
        }
        
        // Add summary at the end to verify all content was included
        widgets.add(pw.SizedBox(height: 20));
        widgets.add(
          pw.Container(
            width: double.infinity,
            padding: pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              border: pw.Border.all(color: PdfColors.grey400, width: 1),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              'Lesson Plan Summary: ${lesson.days?.length ?? 0} days completed',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        );
      }

      return widgets;
        },
      ),
    );
  }

  static pw.Widget _buildDaySection(LessonDay day) {
    final List<pw.Widget> dayWidgets = [];

    // Day header with page break hint
    dayWidgets.add(
      pw.Container(
        width: double.infinity,
        padding: pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: PdfColors.blue50,
          border: pw.Border.all(color: PdfColors.blue300, width: 2),
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.Text(
          'Day ${day.dayNumber ?? '-'}${day.date != null ? " (${day.date})" : ""}',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );

    // Add sessions with optimized spacing
    if (day.sessions != null && day.sessions!.isNotEmpty) {
      for (int i = 0; i < day.sessions!.length; i++) {
        final session = day.sessions![i];
        
        // Add minimal spacing between sessions for better content density
        if (i > 0) {
          dayWidgets.add(pw.SizedBox(height: 8));
        }
        
        dayWidgets.add(_buildSessionSection(session));
      }
    } else {
      dayWidgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.all(8),
          child: pw.Text('No sessions planned.'),
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: dayWidgets,
    );
  }

  static pw.Widget _buildSessionSection(LessonSession session) {
    final List<pw.Widget> sessionWidgets = [];

    // Session header
    sessionWidgets.add(
      pw.Container(
        width: double.infinity,
        padding: pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: PdfColors.green50,
          border: pw.Border.all(color: PdfColors.green300, width: 2),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Text(
          'Hour ${session.hour ?? '-'}: ${session.topic ?? ''}',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green800,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );

         // Objectives
     if (session.objectives != null && session.objectives!.isNotEmpty) {
       sessionWidgets.add(pw.SizedBox(height: 8));
               sessionWidgets.add(
          pw.Container(
            width: double.infinity,
            padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue100,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'OBJECTIVES:',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
          ),
        );
               for (final objective in session.objectives!) {
          // Handle very long objectives by splitting them if needed
          final maxLength = 200; // Maximum characters per line
          if (objective.length > maxLength) {
            // Split long objectives into multiple lines
            final chunks = _splitTextIntoChunks(objective, maxLength);
            for (final chunk in chunks) {
              sessionWidgets.add(
                pw.Padding(
                  padding: pw.EdgeInsets.only(left: 16, top: 4),
                  child: pw.Text(
                    '> $chunk', 
                    style: pw.TextStyle(fontSize: 11),
                    softWrap: true,
                  ),
                ),
              );
            }
          } else {
            sessionWidgets.add(
              pw.Padding(
                padding: pw.EdgeInsets.only(left: 16, top: 4),
                child: pw.Text(
                  '> $objective', 
                  style: pw.TextStyle(fontSize: 11),
                  softWrap: true,
                ),
              ),
            );
          }
        }
     }

     // Activities
     if (session.activities != null && session.activities!.isNotEmpty) {
       sessionWidgets.add(pw.SizedBox(height: 8));
               sessionWidgets.add(
          pw.Container(
            width: double.infinity,
            padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfColors.green100,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'ACTIVITIES:',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green800,
              ),
            ),
          ),
        );
               for (final activity in session.activities!) {
          sessionWidgets.add(
            pw.Padding(
              padding: pw.EdgeInsets.only(left: 16, top: 4),
              child: pw.Text(
                '* $activity', 
                style: pw.TextStyle(fontSize: 11),
                softWrap: true, // Enable text wrapping
              ),
            ),
          );
        }
     }

     // Materials
     if (session.materials != null && session.materials!.isNotEmpty) {
       sessionWidgets.add(pw.SizedBox(height: 8));
               sessionWidgets.add(
          pw.Container(
            width: double.infinity,
            padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfColors.orange100,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'MATERIALS:',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.orange800,
              ),
            ),
          ),
        );
               for (final material in session.materials!) {
          sessionWidgets.add(
            pw.Padding(
              padding: pw.EdgeInsets.only(left: 16, top: 4),
              child: pw.Text(
                '- $material', 
                style: pw.TextStyle(fontSize: 11),
                softWrap: true, // Enable text wrapping
              ),
            ),
          );
        }
     }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: sessionWidgets,
    );
  }

  static void _addGenericContentToPDF(pw.Document pdf, String content) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text(
              content,
              style: pw.TextStyle(fontSize: 14),
            ),
          );
        },
      ),
    );
  }
  
  /// Helper method to split long text into manageable chunks
  static List<String> _splitTextIntoChunks(String text, int maxLength) {
    if (text.length <= maxLength) {
      return [text];
    }
    
    final List<String> chunks = [];
    int startIndex = 0;
    
    while (startIndex < text.length) {
      int endIndex = startIndex + maxLength;
      
      // Try to break at a word boundary
      if (endIndex < text.length) {
        // Look for the last space before maxLength
        int lastSpace = text.lastIndexOf(' ', endIndex);
        if (lastSpace > startIndex) {
          endIndex = lastSpace;
        }
      }
      
      chunks.add(text.substring(startIndex, endIndex).trim());
      startIndex = endIndex;
    }
    
    return chunks;
  }
}
