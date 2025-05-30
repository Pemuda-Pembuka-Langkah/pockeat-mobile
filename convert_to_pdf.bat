@echo off
echo PockEat Technical Documentation - PDF Converter
echo ==================================================

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python not found! Please install Python 3.8 or higher.
    pause
    exit /b 1
)

REM Check if we're in the right directory
if not exist "TECHNICAL_DOCUMENTATION.md" (
    echo Error: TECHNICAL_DOCUMENTATION.md not found!
    echo Please run this script from the pockeat-mobile directory.
    pause
    exit /b 1
)

echo.
echo Installing required packages...
pip install markdown weasyprint pymdown-extensions markdown-toc

echo.
echo Converting documentation to PDF...
python convert_to_pdf.py

if exist "PockEat_Technical_Documentation.pdf" (
    echo.
    echo Success! PDF file created: PockEat_Technical_Documentation.pdf
    echo.
    set /p OPEN="Would you like to open the PDF file? (y/n): "
    if /i "%OPEN%"=="y" start "" "PockEat_Technical_Documentation.pdf"
) else (
    echo.
    echo Error: PDF file was not created. Check for errors above.
)

echo.
pause
