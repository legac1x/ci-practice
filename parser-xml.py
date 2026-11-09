import xml.etree.ElementTree as ET
import os

tree = ET.parse("test-results-3.12.xml")
root = tree.getroot()

testsuite = root.findall("testsuite")
summary_path = os.environ["GITHUB_STEP_SUMMARY"]


for suite in testsuite:
    tests=suite.get("tests")
    failures=suite.get("failures")
    errors=suite.get("errors")
    skipped=suite.get("skipped")
    # print(
    #     f"Total: {tests}", 
    #     f"Passed: {int(tests) - (int(failures) + int(errors) + int(skipped))}", 
    #     f"Failed: {failures}", 
    #     f"Errors: {errors}",
    #     f"Skipped: {skipped}",
    #     sep='\n'
    # )
    with open(summary_path, "a", encoding="utf-8") as file:
        file.write("## Pytest Report \n")
        file.write("| Metric | Value |\n")
        file.write("|---|---|\n")
        file.write(f"| Total | {tests} |\n")
        file.write(f"| Passed | {int(tests) - (int(failures) + int(errors) + int(skipped))} |\n")
        file.write(f"| Failed | {failures} |\n")
        file.write(f"| Errors | {errors} |\n")
        file.write(f"| Skipped | {skipped} |\n")