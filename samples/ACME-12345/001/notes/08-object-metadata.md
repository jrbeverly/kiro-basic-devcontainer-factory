# Notes on SSM Automation S3 Metadata Reading

## Work Item: Read uploaded object's metadata from runbook

### Question
Attempt to read the uploaded object's metadata or tags from inside the runbook.

### Findings

**Status: PARTIALLY SUCCESSFUL**

It IS possible to read S3 object metadata and tags from within an AWS SSM Automation runbook.

### Implementation

Added two new steps to `automation.tf`:

1. **getObjectMetadata** (using S3:HeadObject)
   - Reads object metadata including user-defined `x-amz-meta-*` headers
   - Returns: `Metadata` (StringMap), `ContentType` (String), `ContentLength` (String)
   - Referenced as: `{{steps.getObjectMetadata.Metadata}}`, `{{steps.getObjectMetadata.ContentType}}`

2. **getObjectTags** (using S3:GetObjectTagging)
   - Reads object tags from S3
   - Returns: `TagSet` (StringMap containing array of {Key, Value} pairs)
   - Referenced as: `{{steps.getObjectTags.TagSet}}`

3. **checkContentType** (demonstration)
   - Shows how to use metadata in a conditional branch
   - Checks if `ContentType` equals `video/mp4` to determine processing path
   - Referenced as: `{{steps.getObjectMetadata.ContentType}}`

### Limitations

While metadata can be **read**, there are significant **usability limitations**:

1. **No iteration**: Cannot iterate over metadata map keys or tag array dynamically
2. **No length/count**: Cannot determine count of metadata entries or tags without external scripting
3. **Static key access**: Can only reference specific keys if known at design time
4. **No string functions**: No built-in functions like length(), substring(), etc.
5. **No dynamic processing**: Cannot process unknown metadata keys generically

### Examples

**Reference entire metadata map:**
```
{{steps.getObjectMetadata.Metadata}}
```

**Reference specific metadata key (must know key name):**
```
{{steps.getObjectMetadata.Metadata.myCustomKey}}
```

**Reference entire tag array:**
```
{{steps.getObjectTags.TagSet}}
```

**Reference specific tag by index:**
```
{{steps.getObjectTags.TagSet[0].Key}}
{{steps.getObjectTags.TagSet[0].Value}}
```

### Workarounds for Complex Processing

For generic metadata/tag processing that requires iteration or unknown keys:

1. **aws:executeScript**: Use Lambda with Python/Node.js to process metadata
2. **aws:runCommand**: Run scripts on managed instances
3. **Separate Lambda function**: Extract metadata in a Lambda and call it from Automation

Both require additional IAM permissions and infrastructure.

### Conclusion

The SSM Automation framework can **read** S3 object metadata via HeadObject and GetObjectTagging APIs and **reference** specific values if known. However, for **generic processing** of unknown metadata or tags, additional scripting via Lambda or managed instances is required. This makes it partially suitable for runbook usage depending on the use case.

### Files Modified

- `automation.tf`: Added getObjectMetadata, getObjectTags, and checkContentType steps

### Files Created

- `.factory/notes.md`: This documentation

### Validation

```
terraform validate
Success! The configuration is valid.
```
