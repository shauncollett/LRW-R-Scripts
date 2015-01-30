predict_data_size <- function(numeric_size, number_type = "numeric") {
    if(number_type == "integer") {
        byte_per_number = 4
    } else if(number_type == "numeric") {
        byte_per_number = 8
    } else {
        stop(sprintf("Unknown number_type: %s", number_type))
    }
    estimate_size_in_bytes = (numeric_size * byte_per_number)
    class(estimate_size_in_bytes) = "object_size"
    print(estimate_size_in_bytes, units = "auto")
}

# predict_data_size(1304287*28, "numeric")
# 278.6 Mb