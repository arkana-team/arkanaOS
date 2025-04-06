#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <libtar.h>
#include <lz4.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <errno.h>
#include <popt.h>

#define ARK_MAGIC "ARK\0"
#define ARK_MAGIC_LEN 4
#define BUFFER_SIZE (1024 * 1024)  // 1MB buffer
#define ARK_SEMVER "0.0.1b"

// Function declarations
int create_archive(const char *input_path, const char *output_path);
int extract_archive(const char *input_path, const char *output_path);
void print_usage(const char *program_name);
char* create_temp_filename(const char *prefix);

int main(int argc, char *argv[]) {
    int compress_flag = 0;
    int extract_flag = 0;
    const char *input_path = NULL;
    const char *output_path = NULL;
    int ret = 0;

    // Popt options
    poptContext optCon;
    struct poptOption optionsTable[] = {
        {"compress", 'c', POPT_ARG_NONE, NULL, 'c', "Compress the specified directory", NULL},
        {"extract", 'x', POPT_ARG_NONE, NULL, 'x', "Extract the specified ARK file", NULL},
        {"output", 'o', POPT_ARG_STRING, &output_path, 0, "Specify output file/directory", "PATH"},
        {"help", 'h', POPT_ARG_NONE, NULL, 'h', "Display this help message", NULL},
        {"version", 'v', POPT_ARG_NONE, NULL, 'v', "Display version information", NULL},
        POPT_AUTOHELP
        {NULL, 0, 0, NULL, 0, NULL, NULL}
    };

    optCon = poptGetContext(NULL, argc, (const char **)argv, optionsTable, 0);
    poptSetOtherOptionHelp(optCon, "[OPTIONS]");

    // Parse command line arguments
    while ((ret = poptGetNextOpt(optCon)) >= 0) {
        switch (ret) {
            case 'c':
                compress_flag = 1;
                break;
            case 'x':
                extract_flag = 1;
                break;
            case 'h':
                print_usage(argv[0]);
                poptFreeContext(optCon);
                return 0;
            case 'v':
                printf("arkana archive %s\n", ARK_SEMVER);
                poptFreeContext(optCon);
                return 0;
        }
    }

    if (ret < -1) {
        fprintf(stderr, "error: %s: %s\n", poptBadOption(optCon, POPT_BADOPTION_NOALIAS), poptStrerror(ret));
        poptFreeContext(optCon);
        return 1;
    }

    // Get the input path (non-option argument)
    input_path = poptGetArg(optCon);

    if (!compress_flag && !extract_flag && output_path) {
    	fprintf(stderr, "error: no archive provided\n");
    	print_usage(argv[0]);
    	poptFreeContext(optCon);
    	return 1;
    }

	if (!compress_flag && !extract_flag) {
		fprintf(stderr, "error: no options provided\n");
		print_usage(argv[0]);
		poptFreeContext(optCon);
		return 1;
	}
    
    if (input_path == NULL) {
        fprintf(stderr, "error: no input path specified\n");
        print_usage(argv[0]);
        poptFreeContext(optCon);
        return 1;
    }

    // Validate arguments
    if (compress_flag && extract_flag) {
        fprintf(stderr, "error: cannot use both compression and extraction modes\n");
        print_usage(argv[0]);
        poptFreeContext(optCon);
        return 1;
    }

    if (!compress_flag && !extract_flag) {
        fprintf(stderr, "error: no operation mode specified (use -c or -x)\n");
        print_usage(argv[0]);
        poptFreeContext(optCon);
        return 1;
    }

    if (compress_flag && output_path == NULL) {
        fprintf(stderr, "error: output path (-o) is required with compression (-c) mode\n");
        print_usage(argv[0]);
        poptFreeContext(optCon);
        return 1;
    }

    if (extract_flag && output_path == NULL) {
        // Default to current directory for extraction
        output_path = ".";
    }

    // Perform the requested operation
    if (compress_flag) {
        return create_archive(input_path, output_path);
    } else {
        return extract_archive(input_path, output_path);
    }
}

// Print usage information
void print_usage(const char *program_name) {
    printf("\nUsage:\n");
    printf("  Compression:   %s -c path/to/files -o file.ark\n", program_name);
    printf("  Decompression: %s -x file.ark [-o path/to/extract]\n", program_name);
    printf("\nOptions:\n");
    printf("  -c, --compress       Compress the specified directory\n");
    printf("  -x, --extract        Extract the specified ARK file\n");
    printf("  -o, --output <path>  Specify output file/directory (required for compression)\n");
    printf("  -h, --help           Display this help message\n");
    printf("  -v, --version        Display version information\n");
}

char* create_temp_filename(const char *prefix) {
    const char *tmpdir = getenv("TMPDIR");
    if (tmpdir == NULL) {
        tmpdir = "/tmp";
    }
    
    size_t len = strlen(tmpdir) + strlen(prefix) + 7; // 6 for XXXXXX + 1 for /
    char *temp_filename = malloc(len + 1); // +1 for null terminator
    if (temp_filename == NULL) {
        return NULL;
    }
    
    snprintf(temp_filename, len + 1, "%s/%sXXXXXX", tmpdir, prefix);
    return temp_filename;
}

// Create a temporary tar file from a directory
char* create_temp_tar(const char *directory) {
    char *temp_filename = create_temp_filename("ark_temp_");
    if (temp_filename == NULL) {
        fprintf(stderr, "error: failed to allocate memory for temporary filename\n");
        return NULL;
    }

    int fd = mkstemp(temp_filename);
    if (fd == -1) {
        fprintf(stderr, "error: failed to create temporary file: %s\n", strerror(errno));
        free(temp_filename);
        return NULL;
    }
    close(fd);

    TAR *tar;
    tartype_t tar_ops = {
        (openfunc_t) open,
        (closefunc_t) close,
        (readfunc_t) read,
        (writefunc_t) write
    };

    if (tar_open(&tar, temp_filename, &tar_ops, O_WRONLY | O_CREAT, 0644, TAR_GNU) == -1) {
        fprintf(stderr, "error: failed to open tar file for writing: %s\n", strerror(errno));
        unlink(temp_filename);
        free(temp_filename);
        return NULL;
    }

    // Change to the directory so relative paths work
    char cwd[PATH_MAX];
    if (getcwd(cwd, sizeof(cwd)) == NULL) {
        fprintf(stderr, "error: failed to get current directory: %s\n", strerror(errno));
        tar_close(tar);
        unlink(temp_filename);
        free(temp_filename);
        return NULL;
    }

    if (chdir(directory) != 0) {
        fprintf(stderr, "error: failed to change directory: %s\n", strerror(errno));
        tar_close(tar);
        unlink(temp_filename);
        free(temp_filename);
        return NULL;
    }

    // Add directory contents to tar
    if (tar_append_tree(tar, ".", NULL) != 0) {
        fprintf(stderr, "error: failed to add directory to tar: %s\n", strerror(errno));
        chdir(cwd);  // Change back to original directory
        tar_close(tar);
        unlink(temp_filename);
        free(temp_filename);
        return NULL;
    }

    // Change back to original directory
    if (chdir(cwd) != 0) {
        fprintf(stderr, "error: failed to return to original directory: %s\n", strerror(errno));
        tar_close(tar);
        unlink(temp_filename);
        free(temp_filename);
        return NULL;
    }

    tar_close(tar);
    return temp_filename;
}

// Create an ARK archive
int create_archive(const char *input_path, const char *output_path) {
    // Create temporary tar file
    char *temp_tar = create_temp_tar(input_path);
    if (temp_tar == NULL) {
        fprintf(stderr, "error: failed to create temporary tar file\n");
        return 1;
    }

    // Open the tar file for reading
    FILE *tar_file = fopen(temp_tar, "rb");
    if (tar_file == NULL) {
        fprintf(stderr, "error: failed to open temporary tar file: %s\n", strerror(errno));
        unlink(temp_tar);
        free(temp_tar);
        return 1;
    }

    // Get the size of the tar file
    fseek(tar_file, 0, SEEK_END);
    long tar_size = ftell(tar_file);
    fseek(tar_file, 0, SEEK_SET);

    // Read the tar file into memory
    char *tar_buffer = malloc(tar_size);
    if (tar_buffer == NULL) {
        fprintf(stderr, "fatal: memory allocation failed: %s\n", strerror(errno));
        fclose(tar_file);
        unlink(temp_tar);
        free(temp_tar);
        return 1;
    }

    if (fread(tar_buffer, 1, tar_size, tar_file) != (size_t)tar_size) {
        fprintf(stderr, "error: failed to read tar file: %s\n", strerror(errno));
        free(tar_buffer);
        fclose(tar_file);
        unlink(temp_tar);
        free(temp_tar);
        return 1;
    }

    fclose(tar_file);

    // Compress the tar data with LZ4
    int max_dst_size = LZ4_compressBound(tar_size);
    char *compressed_buffer = malloc(max_dst_size);
    if (compressed_buffer == NULL) {
        fprintf(stderr, "fatal: memory allocation failed: %s\n", strerror(errno));
        free(tar_buffer);
        unlink(temp_tar);
        free(temp_tar);
        return 1;
    }

    int compressed_size = LZ4_compress_default(tar_buffer, compressed_buffer, tar_size, max_dst_size);
    if (compressed_size <= 0) {
        fprintf(stderr, "error: LZ4 compression failed\n");
        free(compressed_buffer);
        free(tar_buffer);
        unlink(temp_tar);
        free(temp_tar);
        return 1;
    }

    // Create ARK file
    FILE *ark_file = fopen(output_path, "wb");
    if (ark_file == NULL) {
        fprintf(stderr, "error: failed to create ARK file: %s\n", strerror(errno));
        free(compressed_buffer);
        free(tar_buffer);
        unlink(temp_tar);
        free(temp_tar);
        return 1;
    }

    // Write ARK magic bytes
    if (fwrite(ARK_MAGIC, 1, ARK_MAGIC_LEN, ark_file) != ARK_MAGIC_LEN) {
        fprintf(stderr, "error: failed to write ARK magic: %s\n", strerror(errno));
        fclose(ark_file);
        free(compressed_buffer);
        free(tar_buffer);
        unlink(temp_tar);
        free(temp_tar);
        return 1;
    }

    // Write compressed data
    if (fwrite(compressed_buffer, 1, compressed_size, ark_file) != (size_t)compressed_size) {
        fprintf(stderr, "error: failed to write compressed data: %s\n", strerror(errno));
        fclose(ark_file);
        free(compressed_buffer);
        free(tar_buffer);
        unlink(temp_tar);
        free(temp_tar);
        return 1;
    }

    fclose(ark_file);

    // Clean up
    free(compressed_buffer);
    free(tar_buffer);
    unlink(temp_tar);
    free(temp_tar);

    return 0;
}

// Extract an ARK archive
int extract_archive(const char *input_path, const char *output_path) {
    // Open ARK file
    FILE *ark_file = fopen(input_path, "rb");
    if (ark_file == NULL) {
        fprintf(stderr, "error: failed to open ARK file: %s\n", strerror(errno));
        return 1;
    }

    // Read and verify magic bytes
    char magic[ARK_MAGIC_LEN];
    if (fread(magic, 1, ARK_MAGIC_LEN, ark_file) != ARK_MAGIC_LEN) {
        fprintf(stderr, "error: failed to read ARK magic: %s\n", strerror(errno));
        fclose(ark_file);
        return 1;
    }

    if (memcmp(magic, ARK_MAGIC, ARK_MAGIC_LEN) != 0) {
        fprintf(stderr, "error: invalid ARK file: magic bytes do not match\n");
        fclose(ark_file);
        return 1;
    }

    // Get the size of the compressed data
    fseek(ark_file, 0, SEEK_END);
    long file_size = ftell(ark_file);
    long compressed_size = file_size - ARK_MAGIC_LEN;
    fseek(ark_file, ARK_MAGIC_LEN, SEEK_SET);

    // Read compressed data
    char *compressed_buffer = malloc(compressed_size);
    if (compressed_buffer == NULL) {
        fprintf(stderr, "fatal: memory allocation failed: %s\n", strerror(errno));
        fclose(ark_file);
        return 1;
    }

    if (fread(compressed_buffer, 1, compressed_size, ark_file) != (size_t)compressed_size) {
        fprintf(stderr, "error: failed to read compressed data: %s\n", strerror(errno));
        free(compressed_buffer);
        fclose(ark_file);
        return 1;
    }

    fclose(ark_file);

    // Create temporary file for decompressed tar
    char *temp_tar = create_temp_filename("ark_extract_");
    if (temp_tar == NULL) {
        fprintf(stderr, "error: failed to allocate memory for temporary filename\n");
        free(compressed_buffer);
        return 1;
    }

    int temp_fd = mkstemp(temp_tar);
    if (temp_fd == -1) {
        fprintf(stderr, "error: failed to create temporary file: %s\n", strerror(errno));
        free(compressed_buffer);
        free(temp_tar);
        return 1;
    }

    // Ensure the output directory exists
    struct stat st = {0};
    if (stat(output_path, &st) == -1) {
        if (mkdir(output_path, 0755) == -1) {
            fprintf(stderr, "error: failed to create output directory: %s\n", strerror(errno));
            close(temp_fd);
            free(compressed_buffer);
            unlink(temp_tar);
            free(temp_tar);
            return 1;
        }
    } else if (!S_ISDIR(st.st_mode)) {
        fprintf(stderr, "error: output path: not a directory\n");
        close(temp_fd);
        free(compressed_buffer);
        unlink(temp_tar);
        free(temp_tar);
        return 1;
    }

    // Decompress data in chunks to handle large files
    FILE *temp_file = fdopen(temp_fd, "wb");
    if (temp_file == NULL) {
        fprintf(stderr, "error: failed to open temporary file: %s\n", strerror(errno));
        close(temp_fd);
        free(compressed_buffer);
        unlink(temp_tar);
        free(temp_tar);
        return 1;
    }

    // For simplicity, we'll decompress the entire file in one go
    // In a real implementation, you might want to read and decompress in chunks

    // First we need to know the decompressed size; let's estimate generously
    // LZ4 usually achieves around 2:1 compression
    long estimated_decompressed_size = compressed_size * 3;
    char *decompressed_buffer = malloc(estimated_decompressed_size);
    if (decompressed_buffer == NULL) {
        fprintf(stderr, "fatal: memory allocation failed: %s\n", strerror(errno));
        fclose(temp_file);
        free(compressed_buffer);
        unlink(temp_tar);
        free(temp_tar);
        return 1;
    }

    int decompressed_size = LZ4_decompress_safe(compressed_buffer, decompressed_buffer,
                                               compressed_size, estimated_decompressed_size);
    if (decompressed_size <= 0) {
        fprintf(stderr, "error: LZ4 decompression failed\n");
        free(decompressed_buffer);
        fclose(temp_file);
        free(compressed_buffer);
        unlink(temp_tar);
        free(temp_tar);
        return 1;
    }

    // Write decompressed data to temporary tar file
    if (fwrite(decompressed_buffer, 1, decompressed_size, temp_file) != (size_t)decompressed_size) {
        fprintf(stderr, "error: failed to write decompressed data: %s\n", strerror(errno));
        free(decompressed_buffer);
        fclose(temp_file);
        free(compressed_buffer);
        unlink(temp_tar);
        free(temp_tar);
        return 1;
    }

    fclose(temp_file);
    free(decompressed_buffer);
    free(compressed_buffer);

    // Extract tar file
    TAR *tar;
    tartype_t tar_ops = {
        (openfunc_t) open,
        (closefunc_t) close,
        (readfunc_t) read,
        (writefunc_t) write
    };

    if (tar_open(&tar, temp_tar, &tar_ops, O_RDONLY, 0, TAR_GNU) == -1) {
        fprintf(stderr, "error: failed to open tar file for reading: %s\n", strerror(errno));
        unlink(temp_tar);
        free(temp_tar);
        return 1;
    }

    // Change to the output directory
    char cwd[PATH_MAX];
    if (getcwd(cwd, sizeof(cwd)) == NULL) {
        fprintf(stderr, "error: failed to get current directory: %s\n", strerror(errno));
        tar_close(tar);
        unlink(temp_tar);
        free(temp_tar);
        return 1;
    }

    if (chdir(output_path) != 0) {
        fprintf(stderr, "error: failed to change to output directory: %s\n", strerror(errno));
        tar_close(tar);
        unlink(temp_tar);
        free(temp_tar);
        return 1;
    }

    // Extract all files
    if (tar_extract_all(tar, ".") != 0) {
        fprintf(stderr, "error: failed to extract tar contents: %s\n", strerror(errno));
        chdir(cwd);
        tar_close(tar);
        unlink(temp_tar);
        free(temp_tar);
        return 1;
    }

    // Return to original directory
    if (chdir(cwd) != 0) {
        fprintf(stderr, "error: failed to return to original directory: %s\n", strerror(errno));
        tar_close(tar);
        unlink(temp_tar);
        free(temp_tar);
        return 1;
    }

    tar_close(tar);
    unlink(temp_tar);
    free(temp_tar);

    return 0;
}

