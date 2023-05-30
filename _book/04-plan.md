# Plan

## Summary of the current progress

We have identified several potential methods for constructing the system. However, there are numerous crucial questions that currently remain unanswered. For instance, we are uncertain whether the system can effectively detect residual departures in a manner similar to humans. To address this, it is necessary to proceed with training the computer vision model and conduct experiments to test the hypothesis.

It is essential to emphasize the importance of accurate training and extensive testing to ensure the reliability and effectiveness of the system. By preparing a wide range of scenarios and collecting comprehensive data, we can gain valuable insights into its capabilities and limitations. Additionally, ongoing evaluation and refinement of the computer vision model will be necessary to address any potential shortcomings.

## Plan for the next step

To facilitate better organization and adherence to the project timeline, a detailed plan is outlined below:

### Define the Objectives

Clearly establish the goals and objectives of the system, including the specific requirements for detecting residual departures. This can be found in the previous chapter.

### Data Prepration

Prepare a diverse and representative dataset that encompasses various types of departures and their corresponding human observations. Types of departures we would like to consider are: 
- Non-linearity
  - Hermite polynomials
- Heteroskedasticity
  - Variance of error as quadratic function of regressor 
- Non-normality
  - Non-normal error
- Autocorrelation
  - AR1 included as predictor 
  
This should cover most of the common model violations of classical normal linear regression model. We have a particular focus on residual vs. fitted values plot, but autocorrelation generally can not be detected by this type of plot.

We would like to prepare at least 10,000 images per type of violation.

### Model Training

Develop and implement a training pipeline that incorporates state-of-the-art computer vision techniques. Train the model using the collected dataset, ensuring a balance between performance and computational efficiency.

We should consider the basic model first, which is a traditional CNN classifier for deciding whether the residual plot is a null plot. Additionally, we need to train a multiclass classifier for providing more useful information on fixing the model violation.

Then, advanced models such as GAN can be considered to follow the lineup protocol more closely. Both the traditional classifier and the GAN models can be discussed in the paper. I am very curious about their performance.

### Testing and Evaluation

Conduct rigorous testing by applying the trained model to a range of real-world scenarios and comparing its performance to human observations. Measure the accuracy, precision, recall, and other relevant metrics to assess the model's effectiveness.



### Iterative refinement

Based on the evaluation results, identify areas where the model may fall short and refine the training process accordingly. Continuously iterate on the model architecture, hyperparameters, and training techniques to improve performance.

## Extension


- Try different type of residual diagnostic plots.
- Try different aesthetics styles.

